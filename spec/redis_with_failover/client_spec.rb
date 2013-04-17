require 'spec_helper'
require 'redis_with_failover/client'

describe RedisWithFailover::Client do

  let(:primary) { Redis.new }
  let(:failover1) { Redis.new }
  let(:failover2) { Redis.new }

  let(:client) { RedisWithFailover::Client.new(servers: [primary, failover1, failover2]) }

  describe 'comparing instances' do
    it 'should not be the same object' do
      primary.object_id.should_not eql(failover1.object_id)
      primary.object_id.should_not eql(failover2.object_id)
    end
  end

  describe 'initialization' do
    it 'raises if no servers are included' do
      expect {
        RedisWithFailover::Client.new
      }.to raise_error(ArgumentError)
    end

    it 'sets failover_proc to block' do
      failover_proc = -> {}
      client = RedisWithFailover::Client.new(servers: [primary], &failover_proc)
      client.failure_callback.should eql(failover_proc)
    end
  end

  describe 'failover' do
    RedisWithFailover::Client::EXCEPTIONS_TO_HANDLE.each do |error|
      context "on #{error.class}" do
        before do
          primary.set('key', 'some value')
        end

        context 'primary redis is working' do
          it 'delegates redis methods to primary server' do
            client.get('key').should eql('some value')
          end
        end

        context 'primary redis throws a connection error' do
          it 'gets data from failover redis' do
            primary.stub(:get).and_raise(error)
            client.get('key').should eql('some value')
          end

          it 'succeeds even if redis response is nil' do\
            primary.stub(:get).and_raise(error)
            expect {
              client.get('unknown_key')
            }.not_to raise_error
          end
        end

        context 'primary and single failover raise connection errors' do
          it 'gets data from first failover redis' do
            primary.stub(:get).and_raise(error)
            failover2.stub(:get).and_raise(error)
            client.get('key').should eql('some value')
          end

          it 'gets data from second failover redis' do
            primary.stub(:get).and_raise(error)
            failover1.stub(:get).and_raise(error)
            client.get('key').should eql('some value')
          end
        end

        context 'primary and all failovers raise connection errors' do
          before do
            primary.stub(:get).and_raise(error)
            failover1.stub(:get).and_raise(error)
            failover2.stub(:get).and_raise(error)
          end

          it 'bubbles up errors' do
            expect {
              client.get('key')
            }.to raise_error(error)
          end

        end
      end
    end

    it 'should not rescue from other errors' do
      primary.stub(:get).and_raise(StandardError)
      expect {
        client.get('key')
      }.to raise_error(StandardError)
    end
  end

  describe 'failover execute proc' do
    it 'should call block when a failover occurs' do
      proc_called = false
      failed_redis = nil
      error = nil
      client.failure_callback = lambda { |failed_redis_server, raised_error|
        proc_called = true
        failed_redis = failed_redis_server
        error = raised_error
      }
      primary.stub(:get).and_raise(Errno::ECONNREFUSED)
      primary.set('key', 'value')
      client.get('key')

      proc_called.should eql(true)
      failed_redis.should eql(primary)
      error.should be_an(Errno::ECONNREFUSED)
    end
  end
end
