require 'spec_helper'

describe NullStatsd do
  let(:statds) { NullStatsd::Statsd.new(host: nil, port: nil, logger: double(:logger, debug:nil)) }

  it 'has a version number' do
    expect(NullStatsd::VERSION).not_to be nil
  end

  describe '#time' do
    it 'executes a block' do
      result = statds.time('time_me') do
        1 + 1
      end
      expect(result).to eq(2)
    end
  end
end
