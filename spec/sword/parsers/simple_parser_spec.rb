require 'rails_helper'

RSpec.describe Sword::Parsers::SimpleParser do
  ########################################## Initial state
  describe 'Initial state' do
    let :simple_parser { Sword::Parsers::SimpleParser.new }
    context '#initialize sets @author_names to' do
      it 'an empty array' do
        expect(simple_parser.author_names).to be_an_instance_of(Array)
        expect(simple_parser.author_names.empty?).to be(true)
      end
    end

    context '#initialize sets @contributor_dept_names to' do
      it 'an empty array' do
        expect(simple_parser.contributor_dept_names).to be_an_instance_of(Array)
        expect(simple_parser.contributor_dept_names.empty?).to be(true)
      end
    end
  end

  ########################################## API/interface
  describe 'API/interface' do
    ########################################## API/interface: attr_accessors
    context 'has attr_accessor for instance var' do
      it 'abstract' do
        expect(subject).to respond_to(:abstract)
        expect(subject).to respond_to(:abstract=)
      end

      it 'author_names' do
        expect(subject).to respond_to(:author_names)
        expect(subject).to respond_to(:author_names=)
      end

      it 'contributor_dept_names' do
        expect(subject).to respond_to(:contributor_dept_names)
        expect(subject).to respond_to(:contributor_dept_names=)
      end

      it 'date' do
        expect(subject).to respond_to(:date)
        expect(subject).to respond_to(:date=)
      end

      it 'title' do
        expect(subject).to respond_to(:title)
        expect(subject).to respond_to(:title=)
      end
    end

    ########################################## API/interface: parse methods
    context ' has the following parsing instance method:' do
      it '#parse method that takes file to parse' do
        expect(subject).to respond_to(:parse).with(1).arguments
      end
      it '#parse_authors helper method parse out the authors' do
        expect(subject).to respond_to(:parse_authors).with(1).arguments
      end
      it '#parse_contributor_dept_names helper method that parses out the contributors' do
        expect(subject).to respond_to(:parse_contributor_dept_names).with(1).arguments
      end
    end
  end

  ########################################## misc methods functionality specs
  describe 'misc methods' do
    describe '#parse' do
      context "In mets file containing expected elements" do
        simple_parser = Sword::Parsers::SimpleParser.new
        mets_file = Rails.root.join "spec/fixtures/mets_files/simple_metadata_mets.xml"
        nokogiri_xml = Nokogiri::XML(mets_file)
        xmlData_as_nokogiri_xml_element =
          nokogiri_xml.xpath('/xmlns:mets/xmlns:dmdSec/xmlns:mdWrap/xmlns:xmlData').first
        simple_parser.parse(xmlData_as_nokogiri_xml_element)

        it "parses the abstract correctly" do
          expect(simple_parser.abstract).to eq "This is the first paragraph that is, it seems."
        end

        it "parses the date issued (start date) correctly" do
          expect(simple_parser.date).to eq "2015"
        end

        it "parses the title correctly" do
          expect(simple_parser.title).to eq "Tow Journalism: The Title That Was"
        end

        context "parses the authors names" do
          it 'parses first author correctly' do
            author = simple_parser.author_names.first
            expect(author.first_name).to eq('Hermione')
            expect(author.last_name).to eq('Granger')
            expect(author.middle_name).to eq('Jean')
          end

          it 'parses second author correctly' do
            author = simple_parser.author_names.second
            expect(author.first_name).to eq('Harry')
            expect(author.last_name).to eq('Potter')
            expect(author.middle_name).to eq('James')
          end
        end

        context "parses the contributor dept names" do
          it 'parses first dept name correctly' do
            dept_name = simple_parser.contributor_dept_names.first
            expect(dept_name.name).to eq('Columbia University. Tow Center for Digital Journalism')
          end

          it 'parses second dept name correctly' do
            dept_name = simple_parser.contributor_dept_names.second
            expect(dept_name.name).to eq('Columbia University. Journalism')
          end
        end
      end
    end
  end
end
