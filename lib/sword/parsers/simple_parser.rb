module Sword
  module Parsers
    class SimpleParser

      attr_accessor :abstract,
                    :author_names,
                    :contributor_dept_names,
                    :date,
                    :title

      def initialize
        @author_names = []
        @contributor_dept_names = []
      end

      def parse(xmlData_nokogiri_xml)
        @abstract = xmlData_nokogiri_xml.css('submission>content>abstract').text
        @date = xmlData_nokogiri_xml.css('submission>description>dates>date').text
        @title = xmlData_nokogiri_xml.css('submission>description>title').text
        parse_authors xmlData_nokogiri_xml
        parse_contributor_dept_names xmlData_nokogiri_xml
      end

      def parse_authors(nokogiri_xml)
        nokogiri_xml.css("submission>authorship>author>name").each do |author|
          person = Sword::Metadata::PersonalName.new
          person.last_name = author.css("surname").text
          person.first_name = author.css("fname").text
          person.middle_name = author.css("middle").text
          person.role = 'author'
          @author_names << person
        end
      end

      def parse_contributor_dept_names(nokogiri_xml)
        nokogiri_xml.css("description>contributor>dept_name").each do |dept_name|
          corporate = Sword::Metadata::CorporateName.new
          corporate.name = dept_name.text
          corporate.role = 'contributor'
          @contributor_dept_names << corporate
        end
      end
    end
  end
end
