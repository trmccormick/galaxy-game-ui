FactoryBot.define do
  factory :graduate_record do
    sequence(:crm_id) { |n| "WVU-TEST#{format('%05d', n)}" }
    first_name { "Jordan" }
    surname { "Rivers" }
    data do
      {
        "Primary Constituency" => "Alumni Association",
        "Educational/College Code" => "COE",
        "Educational Sub-Department Code" => "CSC",
        "Class Year" => "2015"
      }
    end
    waiver_completed { false }
    notes { nil }

    trait :waiver_completed do
      waiver_completed { true }
      notes { "Confirmed at check-in." }
    end
  end
end
