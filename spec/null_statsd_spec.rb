require "spec_helper"
require "logger"

describe NullStatsd::Statsd do
  let(:logger) { instance_double(Logger, debug: nil) }
  let(:statsd) { NullStatsd::Statsd.new(host: nil, port: nil, logger: logger) }

  it "has a version number" do
    expect(NullStatsd::VERSION).not_to be nil
  end

  describe "#time" do
    it "executes a block" do
      result = statsd.time("time_me") { 1 + 1 }
      expect(result).to eq(2)
    end

    it "logs the expected message with no tags" do
      statsd.time("time_me") { 1 + 1 }
      expect(logger).to have_received(:debug)
        .with(a_string_matching(/^\[NullStatsD [^\]]+\] Recording timing info in time_me -> \S+ sec$/))
    end

    it "logs the expected message with tags" do
      statsd.time("time_me", tags: ["a:b", "c:2"]) { 1 + 1 }
      expect(logger).to have_received(:debug)
        .with(a_string_matching(/^\[NullStatsD [^\]]+\] Recording .* time_me -> \S+ sec with opts {"tags":\["a:b","c:2"\]}$/))
    end
  end

  shared_examples_for "a statsd method" do |method_name|
    before { @null_statsd = statsd }

    context "without options" do
      let(:method) { ->(args, opts = {}) { @null_statsd.send(method_name, *args, opts) } }
      let(:expected_key) { args.first }

      it "exists" do
        expect { method.call(args) }.not_to raise_error
      end

      context "while in a namespace" do
        before { @null_statsd = @null_statsd.with_namespace("foo") }
        it "logs a message with the namespace in the identifier" do
          method.call(args)
          expect(logger).to have_received(:debug).with(match expected_key)
          expect(logger).to have_received(:debug).with(match /\[NullStatsD :-foo\]/)
        end
      end

      context "without options" do
        it "logs a message containing the proper key" do
          method.call(args)
          expect(logger).to have_received(:debug).with(match expected_key)
        end
      end

      context "with options" do
        let(:opts) { { foo: "bar", baz: "zork" } }
        let(:expected_opts) { '{"foo":"bar","baz":"zork"}' }

        it "logs a message containing the proper string" do
          method.call(args, opts)
          expect(logger).to have_received(:debug).with(match expected_opts)
        end

        context "when options contain an array" do
          let(:opts) { { foo: ["baz", "bak", "bat"] } }
          let(:expected_opts) { /{"foo":\["baz","bak","bat"\]}/ }

          it "logs a message containing the proper string" do
            method.call(args, opts)
            expect(logger).to have_received(:debug).with(match expected_opts)
          end
        end
      end
    end
  end

  describe "Statsd fakes" do
    describe "#close" do
      it "logs the proper message" do
        statsd.close
        expect(logger).to have_received(:debug).with(match "Close called")
      end
    end

    describe "#batch" do
      it "yields itself to the given block" do
        statsd.batch do |instance|
          expect(instance).to eq statsd
        end
      end
    end

    describe "single arg methods" do
      let(:args) { ["stat"] }

      describe "#increment" do
        it_behaves_like "a statsd method", :increment
      end

      describe "#decrement" do
        it_behaves_like "a statsd method", :decrement
      end
    end

    describe "key/value metrics" do
      let(:args) { ["stat", "value"] }

      describe "#count" do
        it_behaves_like "a statsd method", :count
      end

      describe "#gauge" do
        it_behaves_like "a statsd method", :gauge
      end

      describe "#histogram" do
        it_behaves_like "a statsd method", :histogram
      end

      describe "#set" do
        it_behaves_like "a statsd method", :set
      end

      describe "#service_check" do
        it_behaves_like "a statsd method", :service_check
      end

      describe "#event" do
        it_behaves_like "a statsd method", :event
      end
    end

    describe "#timing" do
      let(:args) { ["stat", 42, 1] }
      it_behaves_like "a statsd method", :timing
    end
  end

  describe "#with_namespace" do
    let(:namespace) { "Foo" }
    subject(:with_namespace) { statsd.with_namespace(namespace) }

    context "without a &block" do
      it "returns a `dup` of itself" do
        expect(with_namespace.hash).not_to eq statsd.hash
      end
    end

    context "with a &block given" do
      it "yields a properly namespaced dup of itself to the block" do
        statsd.with_namespace(namespace) do |ns_statsd|
          expect(ns_statsd.namespace).to eq namespace
          expect(ns_statsd.hash).not_to eq statsd.hash
        end
      end
    end

    context "for an object without a namespace" do
      it "adds the namespace" do
        expect(with_namespace.namespace).to eq namespace
      end
    end

    context "for an object already containing a namespace" do
      subject(:with_preexisting_namespace) { with_namespace.with_namespace(namespace) }

      it "adds the namespace" do
        expect(with_preexisting_namespace.namespace).to eq "#{namespace}.#{namespace}"
      end
    end
  end
end
