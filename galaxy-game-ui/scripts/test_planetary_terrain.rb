# frozen_string_literal: true

# Test PlanetaryTerrainService against all five configured datasets.
# Run with: rails runner scripts/test_planetary_terrain.rb

require_relative '../config/environment'

puts "=" * 80
puts "PlanetaryTerrainService — Dataset Test"
puts "=" * 80

bodies = %i[earth mars venus luna titan]
results = []

bodies.each do |body|
  puts "\n" + "-" * 60
  puts "Testing: #{body.upcase}"
  puts "-" * 60

  begin
    info = PlanetaryTerrainService.body_info(body)
    source = info[:source_file]
    exists = File.exist?(source)

    puts "  Source file: #{source}"
    puts "  Exists:      #{exists ? 'YES' : 'NO'}"
    puts "  Configured:  #{info[:width]}x#{info[:height]}"
    puts "  Description: #{info[:description]}"

    unless exists
      puts "  SKIPPED — file not mounted"
      results << { body:, status: 'skipped', error: 'file_not_mounted' }
      next
    end

    # Time the load
    start = Time.now
    terrain = PlanetaryTerrainService.load_terrain(body)
    elapsed = (Time.now - start).round(2)

    puts "  Status:      SUCCESS"
    puts "  Grid size:   #{terrain[:width]}x#{terrain[:height]}"
    puts "  Elevation:   #{terrain[:elevation_range][:min]} to #{terrain[:elevation_range][:max]} #{terrain[:elevation_range][:unit]}"
    puts "  NoData val:  #{terrain[:nodata_value]}"
    puts "  Processed at:#{terrain[:processed_at]}"

    # Verify grid has real data (not all zeros or nulls)
    flat = terrain[:elevation].flatten.compact
    unique_vals = flat.uniq.size
    min_val = flat.min
    max_val = flat.max
    nonzero_count = flat.count { |v| v != 0 && !v.nil? }

    puts "  Grid values: #{flat.size} total, #{unique_vals} unique"
    puts "  Normalized:  #{min_val.round(4)} to #{max_val.round(4)}"
    puts "  Non-zero:    #{nonzero_count}"
    puts "  Time:        #{elapsed}s"

    # Check for empty/blank terrain
    if flat.empty?
      puts "  WARNING: Empty grid!"
      results << { body:, status: 'error', error: 'empty_grid' }
    elsif nonzero_count == 0
      puts "  WARNING: All values are zero — no elevation variation"
      results << { body:, status: 'warning', error: 'no_variation' }
    else
      puts "  VERIFIED: Real elevation data present"
      results << { body:, status: 'ok', grid_size: "#{terrain[:width]}x#{terrain[:height]}", elapsed: }
    end

    # Clear cache for next test
    Rails.cache.delete("planetary_terrain_#{body}")

  rescue => e
    puts "  ERROR: #{e.class}: #{e.message}"
    results << { body:, status: 'error', error: e.message }
  end
end

# Summary
puts "\n" + "=" * 80
puts "SUMMARY"
puts "=" * 80
results.each do |r|
  case r[:status]
  when 'ok'
    puts "  #{r[:body].to_s.upcase.ljust(8)} OK — #{r[:grid_size]} in #{r[:elapsed]}s"
  when 'warning'
    puts "  #{r[:body].to_s.upcase.ljust(8)} WARNING — #{r[:error]}"
  when 'skipped'
    puts "  #{r[:body].to_s.upcase.ljust(8)} SKIPPED — #{r[:error]}"
  when 'error'
    puts "  #{r[:body].to_s.upcase.ljust(8)} ERROR — #{r[:error]}"
  end
end

ok_count = results.count { |r| r[:status] == 'ok' }
puts "\n#{ok_count}/#{results.size} bodies loaded successfully"
puts "=" * 80
