require 'debt_collector/collector'

class DebtCollector

  def self.collect(options={})
    Collector.new(options).collect
  end
end
