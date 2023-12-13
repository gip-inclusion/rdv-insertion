module Counters
  class RdvsTakenByPrescripteur
    include Statisfy::Counter

    count every: :participation_created,
          if: -> { participation.created_by == "prescripteur" }
  end
end
