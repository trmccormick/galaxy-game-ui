# frozen_string_literal: true

# PlanetaryTerrainService — loads GeoTIFF elevation data for planetary bodies
# and supplies normalized elevation grids to the planetary renderer.
#
# Uses GDAL CLI tools (gdalinfo, gdal_translate) for reading/downsampling.
# Caches processed results in Rails.cache to avoid reprocessing on every request.

class PlanetaryTerrainService
  # Body-specific configuration: source file, display resolution, elevation metadata
  BODY_CONFIG = {
    earth: {
      source_file: '/mnt/geotiff/raw/earth_etopo_2022.tif',
      width: 1800,
      height: 900,
      elevation_unit: 'meters (EGM2008)',
      description: 'ETOPO 2022 global relief model'
    },
    mars: {
      source_file: '/mnt/geotiff/raw/mars_mola_463m.tif',
      width: 1800,
      height: 900,
      elevation_unit: 'meters (MOLA)',
      description: 'Mars Orbiter Laser Altimeter (MOLA) data'
    },
    venus: {
      source_file: '/mnt/geotiff/raw/venus_magellan_4641m.tif',
      width: 1800,
      height: 900,
      elevation_unit: 'meters (Magellan radar)',
      description: 'Magellan radar topography data'
    },
    luna: {
      source_file: '/mnt/geotiff/raw/luna_lola_118m.tif',
      width: 1800,
      height: 900,
      elevation_unit: 'meters (LOLA)',
      description: 'Lunar Orbiter Laser Altimeter (LOLA) data'
    },
    titan: {
      source_file: '/mnt/geotiff/processed/titan_1800x900_final.tif',
      width: 1800,
      height: 900,
      elevation_unit: 'meters (Cassini)',
      description: 'Cassini radar topography (pre-processed 1800x900)'
    }
  }.freeze

  def self.load_terrain(body)
    new(body).load_terrain
  end

  def self.available_bodies
    BODY_CONFIG.keys
  end

  def self.body_info(body)
    BODY_CONFIG[body.to_sym]&.merge(source_exists: File.exist?(BODY_CONFIG[body.to_sym][:source_file]))
  end

  def initialize(body)
    @body = body.to_sym
    raise ArgumentError, "Unknown body: #{body}" unless BODY_CONFIG.key?(@body)
  end

  attr_reader :body

  def load_terrain
    # Check cache first
    cached = Rails.cache.read(cache_key)
    return cached if cached

    result = fetch_and_process
    Rails.cache.write(cache_key, result, expires_in: 24.hours)
    result
  end

  private

  attr_reader :body

  def config
    BODY_CONFIG[body]
  end

  def cache_key
    "planetary_terrain_#{body}"
  end

  def fetch_and_process
    source = config[:source_file]

    unless File.exist?(source)
      raise FileNotFoundError, "GeoTIFF not found: #{source}"
    end

    # Use GDAL to get info and downsample in one step
    elevation_data = read_with_gdal(source)

    # Compute statistics on raw (pre-normalization) values
    flat_values = elevation_data[:elevation].flatten.reject { |v| v.nil? || v == elevation_data[:nodata_value] }
    min_elev = flat_values.min
    max_elev = flat_values.max
    elev_range = max_elev - min_elev

    # Normalize to 0-1 for renderer coloring
    normalized_grid = if elev_range > 0
      elevation_data[:elevation].map do |row|
        row.map do |val|
          next nil if val.nil? || val == elevation_data[:nodata_value]
          (val - min_elev) / elev_range
        end
      end
    else
      # Constant elevation — all zeros
      elevation_data[:elevation].map { |row| row.map { |_v| 0.0 } }
    end

    {
      body: body,
      source_file: source,
      width: normalized_grid.first&.size || 0,
      height: normalized_grid.size,
      elevation: normalized_grid,
      elevation_range: {
        min: min_elev,
        max: max_elev,
        unit: config[:elevation_unit]
      },
      nodata_value: elevation_data[:nodata_value],
      description: config[:description],
      processed_at: Time.current.iso8601
    }
  end

  # Read GeoTIFF via GDAL CLI with downsampling to target resolution.
  # Uses Python GDAL (osgeo.gdal) for reliable reading of all GeoTIFF types,
  # including non-square pixel sources like Venus that break AAIGrid output.
  def read_with_gdal(filepath)
    target_w = config[:width]
    target_h = config[:height]

    # Get NoData value from source file
    nodata_value = extract_nodata(filepath)

    # Use Python GDAL to read and downsample the GeoTIFF directly.
    # This avoids AAIGrid format limitations (DX/DY headers for non-square pixels).
    python_script = <<~PYTHON
      import sys
      from osgeo import gdal, gdal_array
      import numpy as np

      filepath = sys.argv[1]
      target_w = int(sys.argv[2])
      target_h = int(sys.argv[3])
      nodata = float(sys.argv[4])

      ds = gdal.Open(filepath)
      if ds is None:
          print(f"ERROR: Cannot open {filepath}", file=sys.stderr)
          sys.exit(1)

      band = ds.GetRasterBand(1)
      raw_nodata = band.GetNoData()
      if raw_nodata is None:
          raw_nodata = nodata

      # Read the full raster as numpy array
      data = band.ReadAsArray().astype(np.float32)

      # Replace NoData with NaN for proper resampling
      data[data == raw_nodata] = np.nan

      # Downsample using gdal.ReprojectImage or average pooling
      # For large files, use block-by-block averaging to avoid memory issues
      src_xsize = ds.RasterXSize
      src_ysize = ds.RasterYSize

      if src_xsize == target_w and src_ysize == target_h:
          # No downsampling needed
          result = data
      else:
          # Use gdal.ReprojectImage with average resampling
          # Create a virtual dataset with the target geotransform
          gt = ds.GetGeoTransform()
          new_gt = [
              gt[0], gt[1] * (src_xsize / target_w),
              gt[2], gt[3], gt[4] * (src_ysize / target_h), gt[5]
          ]

          # Use gdal.Translate for resampling with average method
          options = ['RESAMPLING=AVERAGE', f'OUTSIZE={target_w} {target_h}', 'NODATA=']
          temp_ds = gdal.Translate('', ds, format='MEM', **{opt.split('=')[0]: opt.split('=')[1] if '=' in opt else '' for opt in options})
          result = temp_ds.GetRasterBand(1).ReadAsArray().astype(np.float32)

      # Replace NaN back with nodata marker
      result = np.nan_to_num(result, nan=nodata)

      # Output as space-separated rows (one per line)
      for row in result:
          print(' '.join(f'{v:.6f}' for v in row))
    PYTHON

    temp_py = "/tmp/terrain_#{body}_#{Time.now.to_i}.py"
    File.write(temp_py, python_script)

    output = `python3 #{temp_py} "#{filepath}" #{target_w} #{target_h} #{nodata_value} 2>&1`
    File.delete(temp_py) if File.exist?(temp_py)

    unless $?.success?
      raise GDALExecutionError, "Python GDAL failed for: #{filepath}\n#{output}"
    end

    # Parse the output into a grid
    lines = output.strip.split("\n")
    ncols = lines.first&.split&.size || 0
    nrows = lines.size

    elevation_data = lines.map do |line|
      line.split.map { |v| (val = v.to_f) == nodata_value ? nodata_value : val }
    end

    {
      width: ncols,
      height: nrows,
      elevation: elevation_data,
      nodata_value: nodata_value
    }
  end

  # Extract NoData value from GeoTIFF using gdalinfo
  def extract_nodata(filepath)
    output = `gdalinfo "#{filepath}" 2>&1`

    # Try explicit NoData Value line first
    nodata_match = output.match(/NoData Value=(-?\d+(?:\.\d+)?)/)
    return nodata_match[1].to_f if nodata_match

    # Try NULL value for NetCDF/other formats
    null_match = output.match(/NULL value=(-?\d+(?:\.\d+)?)/)
    return null_match[1].to_f if null_match

    # Default fallback
    -9999.0
  end

  # Parse AAIGrid (ASCII Grid) format output from gdal_translate.
  # Handles both standard CELLSIZE and Golden Surfer DX/DY formats.
  def parse_ascii_grid(path, nodata_value)
    lines = File.readlines(path)

    # Parse header (first 6 lines)
    header = {}
    lines[0..5].each do |line|
      parts = line.strip.split
      next unless parts.size >= 2
      key = parts[0].downcase
      value = parts[1]
      header[key] = value
    end

    # Handle Golden Surfer style files (non-square pixels use DX/DY instead of CELLSIZE)
    if header.key?('dx') && header.key?('dy')
      ncols = header['ncols'].to_i
      nrows = header['nrows'].to_i
    else
      ncols = (header['ncols'] || 0).to_i
      nrows = (header['nrows'] || 0).to_i
    end

    # Parse elevation data (skip header lines)
    # IMPORTANT: Use actual column count from first data row, not the header.
    # DX/DY (Golden Surfer) format writes ncols/nrows in headers but the actual
    # data rows may have different structure — always trust the data.
    elevation_data = []
    actual_ncols = nil
    lines[6..-1].each do |line|
      values = line.strip.split.map { |v| v.to_f }
      actual_ncols ||= values.size  # First row determines true column count
      val = values.map { |v| v == nodata_value ? nodata_value : v }
      elevation_data << val
    end

    {
      width: actual_ncols || ncols,
      height: elevation_data.size,
      elevation: elevation_data,
      nodata_value: nodata_value
    }
  end
  class FileNotFoundError < StandardError; end
  class GDALExecutionError < StandardError; end
end
