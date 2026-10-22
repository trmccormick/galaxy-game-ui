module ApplicationHelper
  # Returns descriptive text for a system based on its identifier.
  def system_identifier_description(system_id)
    case system_id.to_s.upcase
    when "SOL" then "Your home system. Stable, resourced."
    when "EDEN" then "A frontier outpost. Opportunity awaits."
    else "Unknown territory. Risk and reward."
    end
  end

  # Maps a system's numeric stability (0.0-1.0) to the CSS class suffix
  # used by .stability-stable / .stability-stabilizing / .stability-unstable
  def system_stability_class(system)
    value = system[:stability_index_base].to_f
    if value >= 0.8
      "stable"
    elsif value >= 0.5
      "stabilizing"
    else
      "unstable"
    end
  end
end