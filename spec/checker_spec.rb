require 'helper'
require 'checker'

describe Checker do
  before do
    subject.logger = Logger.new('/dev/null')
  end

  describe '#start' do
    it 'loops over the routing' do
      expect(subject).to receive(:loop)
      subject.start
    end
  end

  describe '#job' do
    before do
      allow(subject).to receive(:sleep)
    end

    context 'without exceptions' do
      it 'checks and send mails' do
        allow(subject).to receive(:on_sale?).and_return(true)
        allow(subject).to receive(:exit)
        expect(subject).to receive(:send_mail)

        subject.job.call
      end
    end

    context 'with exceptions' do
      let(:exception) { StandardError.new('foo') }

      it 'send mails with exception' do
        allow(subject).to receive(:on_sale?).and_raise(exception)
        expect(subject).to receive(:send_mail).with(exception.to_s, subject: 'Error checking tickets!')

        subject.job.call
      end
    end
  end

  describe '#on_sale?' do
    before do
      allow(Net::HTTP).to receive(:get).with('www.reallyusefultheatres.co.uk', '/buy-tickets').and_return(body)
    end

    context 'without tickets' do
      let(:body) { 'no tickets for our live concert' }

      it 'returns false' do
        expect(subject.on_sale?).to be_eql(false)
      end
    end

    context 'with damien tickets' do
      let(:body) { 'oh man!! damien rice tickets are on sale!!!' }

      it 'returns true' do
        expect(subject.on_sale?).to be_eql(true)
      end
    end
  end
end
