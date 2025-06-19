require 'webmock/rspec'
require 'tempfile'
require_relative '../lib/client_manager'

RSpec.describe ClientManager do
  let(:test_data) do
    [
      { 'id' => 1, 'full_name' => 'John Doe', 'email' => 'john@example.com' },
      { 'id' => 2, 'full_name' => 'Jane Smith', 'email' => 'jane@example.com' },
      { 'id' => 3, 'full_name' => 'John Smith', 'email' => 'john@example.com' },
      { 'id' => 4, 'full_name' => 'Alice Wonderland', 'email' => 'alice@example.com' },
      { 'id' => 5, 'full_name' => nil, 'email' => 'test@example.com' },
      { 'id' => 6, 'full_name' => 'No Email', 'email' => nil },
      { 'id' => 7, 'full_name' => 'Empty Email', 'email' => '' },
      { 'id' => 8, 'full_name' => 'UPPER CASE', 'email' => 'UPPER@EXAMPLE.COM' }
    ]
  end

  subject { described_class.new(test_data) }

  describe '#search_by_name' do
    context 'with matching names' do
      it 'returns clients with partial matches' do
        results = subject.search_by_name('John')
        expect(results.map { |c| c['id'] }).to contain_exactly(1, 3)
      end

      it 'is case insensitive' do
        results = subject.search_by_name('JOHN')
        expect(results.map { |c| c['id'] }).to contain_exactly(1, 3)
      end

      it 'matches uppercase names with lowercase query' do
        results = subject.search_by_name('upper')
        expect(results.map { |c| c['id'] }).to contain_exactly(8)
      end
    end

    context 'with edge cases' do
      it 'handles nil names gracefully' do
        expect(subject.search_by_name('test')).to be_empty
      end

      it 'returns empty array for empty query' do
        expect(subject.search_by_name('')).to be_empty
      end

      it 'returns empty array for nil query' do
        expect(subject.search_by_name(nil)).to be_empty
      end

      it 'returns empty array for no matches' do
        expect(subject.search_by_name('xyz')).to be_empty
      end
    end
  end

  describe '#find_duplicate_emails' do
    it 'finds exact email duplicates' do
      duplicates = subject.find_duplicate_emails
      expect(duplicates.keys).to contain_exactly('john@example.com')
    end

    it 'is case insensitive for emails' do
      duplicates = subject.find_duplicate_emails
      expect(duplicates.keys).to contain_exactly('john@example.com')
      
      upper_case_client = test_data.find { |c| c['email'] == 'UPPER@EXAMPLE.COM' }
      expect(upper_case_client['email'].downcase).to eq('upper@example.com')
    end

    context 'with edge cases' do
      it 'ignores nil emails' do
        expect(subject.find_duplicate_emails.keys).not_to include(nil)
      end

      it 'ignores empty string emails' do
        expect(subject.find_duplicate_emails.keys).not_to include('')
      end

      it 'returns empty hash when no duplicates exist' do
        single_client = [test_data.first]
        manager = described_class.new(single_client)
        expect(manager.find_duplicate_emails).to be_empty
      end
    end
  end

  describe 'data loading' do
    before do
      stub_request(:get, "http://example.com/data.json")
        .to_return(body: '[{"id": 1, "full_name": "Test"}]')
    end

    it 'handles remote JSON sources' do
      manager = described_class.new('http://example.com/data.json')
      expect(manager.clients.size).to eq(1)
    end

    it 'handles local file sources' do
      Tempfile.create('test.json') do |file|
        file.write('[{"id": 1}]')
        file.close
        manager = described_class.new(file.path)
        expect(manager.clients.size).to eq(1)
      end
    end

    it 'returns empty array for invalid sources' do
      manager = described_class.new('invalid/path.json')
      expect(manager.clients).to eq([])
    end
  end
end
