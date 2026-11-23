require "rails_helper"

RSpec.describe MockAiManagerApi do
  subject(:api) { described_class.new }

  describe "#systems" do
    it "provides replaceable Sol and Eden fixture contexts" do
      expect(api.systems.map { |system| system[:id] }).to eq(%w[sol eden])
      expect(api.systems).to all(include(scope: "NPC operations"))
    end
  end

  describe "#resolve_system" do
    it "preserves a valid selected system" do
      expect(api.resolve_system("eden")).to eq("eden")
    end

    it "falls back to the first available fixture for an unknown system" do
      expect(api.resolve_system("unknown")).to eq(api.systems.first[:id])
    end
  end

  describe "#tasks" do
    it "filters tasks by system context and provides display status labels" do
      tasks = api.tasks(system_id: "sol")

      expect(tasks.map { |task| task[:id] }).to eq(%w[TASK-SOL-001 TASK-SOL-002 TASK-SOL-003])
      expect(tasks.find { |task| task[:id] == "TASK-SOL-001" }[:status_label]).to eq("Needs attention")
    end
  end

  describe "#overview" do
    it "summarizes objectives, conditions, queue states, and linked decision examples" do
      overview = api.overview(system_id: "sol")

      expect(overview[:system][:id]).to eq("sol")
      expect(overview[:counts]).to eq(attention: 1, queued: 0, active: 1, blocked: 1, completed: 0)
      expect(overview[:objectives].map { |task| task[:id] }).to match_array(%w[TASK-SOL-001 TASK-SOL-002 TASK-SOL-003])
      expect(overview[:conditions].map { |task| task[:status] }).to match_array(%w[awaiting_review blocked])
      expect(overview[:recent_decisions].map { |decision| decision[:task_id] }).to all(be_present)
      expect(overview[:source_label]).to include("not connected to the simulation")
    end
  end

  describe "#plan and #execution" do
    it "returns the source-linked Venus arrival procedure in the plan fixture" do
      task = api.task("TASK-SOL-003")
      plan = api.plan(task)

      expect(plan[:procedure][:id]).to eq("task_venus_harvest_arrival_v2")
      expect(plan[:resources].map { |resource| resource[:name] }).to include("N₂ payload", "CO₂ payload")
    end

    it "returns a mock execution record without implying live dispatch" do
      execution = api.execution(api.task("TASK-SOL-002"))

      expect(execution[:status]).to eq("In progress (mock)")
      expect(execution[:progress]).to eq(45)
      expect(execution[:events]).to include(a_string_matching(/Target resolved/))
    end
  end
end
