FactoryBot.define do
  factory :graduate_record do
    sequence(:crm_id) { |n| "WVU-TEST#{format('%05d', n)}" }
    first_name { "Jordan" }
    surname { "Rivers" }
    primary_constituency { "Alumni Association" }
    college_code { "COE" }
    sub_department_code { "CSC" }
    class_year { "2015" }
    waiver_completed { false }
    notes { nil }

    trait :waiver_completed do
      waiver_completed { true }
      notes { "Confirmed at check-in." }
    end
  end
end
