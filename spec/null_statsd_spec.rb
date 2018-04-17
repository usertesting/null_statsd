require 'spec_helper'

describe NullStatsd do
  let(:logger) { double(:logger, debug: nil)}
  let(:statsd) { NullStatsd::Statsd.new(host: nil, port: nil, logger: logger) }

  it 'has a version number' do
    expect(NullStatsd::VERSION).not_to be nil
  end

  describe '#time' do
    it 'executes a block' do
      result = statsd.time('time_me') do
        1 + 1
      end
      expect(result).to eq(2)
    end
  end

  shared_examples_for "a statsd method" do
    before do
      @null_statsd = statsd
    end

    describe "without options" do
      let(:method) { ->(args, opts = {}) { @null_statsd.send(method_name, *args, opts) } }
      let(:expected_key) { args.join('|') }

      it "exists" do
        expect { method.call(args) }.not_to raise_error
      end

      describe "without options" do
        it "logs a message containing the proper key" do
          method.call(args)
          expect(logger).to have_received(:debug).with(match expected_key)
        end
      end

      describe "with options" do
        let(:opts) { { foo: 'bar', baz: 'zork' } }
        let(:expected_key) { args.first + '\|foo:bar\|baz:zork' }

        it "logs a message containing the proper key" do
          method.call(args, opts)
          expect(logger).to have_received(:debug).with(match expected_key)
        end

        describe "when options contain an array" do
          let(:opts) { { foo: ['baz', 'bak', 'bat'] } }
          let(:expected_key) { args.first + "\|foo:baz,bak,bat" }

          it "logs a message containing the proper key" do
            method.call(args, opts)
            expect(logger).to have_received(:debug).with(match expected_key)
          end
        end
      end
    end
  end

  describe "Statsd fakes" do
    describe "single key methods" do
      let(:args) { [ 'stat' ] }

      describe ".increment" do
        it_behaves_like "a statsd method" do
          let(:method_name) { :increment }
        end
      end

      describe ".decrement" do
        it_behaves_like "a statsd method" do
          let(:method_name) { :decrement }
        end
      end
    end

    describe "key/value metrics" do
      let(:args) { [ 'stat', 'value' ] }

      describe ".count" do
        it_behaves_like "a statsd method" do
          let(:method_name) { :count }
        end
      end

      describe ".guage" do
        it_behaves_like "a statsd method" do
          let(:method_name) { :gauge }
        end
      end

      describe '.histogram' do
        it_behaves_like "a statsd method" do
          let(:method_name) { :histogram }
        end
      end

      describe '.set' do
        it_behaves_like "a statsd method" do
          let(:method_name) { :set }
        end
      end

      describe '.service_check' do
        it_behaves_like "a statsd method" do
          let(:method_name) { :service_check }
        end
      end

      describe '.event' do
        it_behaves_like "a statsd method" do
          let(:method_name) { :event }
        end
      end
    end
  end
end
