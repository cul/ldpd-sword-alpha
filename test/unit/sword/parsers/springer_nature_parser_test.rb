require 'test_helper'
require 'sword/parsers/springer_nature_parser'

class SpringerNatureParserTest < ActiveSupport::TestCase
  setup do
    @parser = Sword::Parsers::SpringerNatureParser.new
  end

  test "parse correctly" do
    content_dir = File.dirname(fixture_path_for('springer_nature/mets.xml'))
    parser = Sword::Parsers::SpringerNatureParser.new
    deposit = parser.parse(content_dir, nil)
    assert deposit.is_a? Sword::DepositContent
    assert_equal 'This is the title of the fake Springer Nature Article', deposit.title
    expected_abstract_value = fixture_file 'springer_nature/expected_abstract_value.txt'
    assert_equal expected_abstract_value, deposit.abstract
    assert_equal '10.1186/s13033-015-0032-8', deposit.pub_doi
    assert_equal '2016', deposit.dateIssued
    assert_equal 'Mental health systems, Mozambique, Psychiatric technician, Scaling-up services', deposit.note
    assert_equal 'International Journal of Stuff', deposit.parent_publication_title
    assert_equal '2016', deposit.pubdate
    assert_equal '10', deposit.volume
    assert_equal '11', deposit.issue
    assert_equal '78', deposit.fpage

    result =  deposit.authors.any? do |person|
      person.full_name_naf_format == 'Birdie, Fred'
    end
    assert result, 'Author "Birdie, Fred" not found'
    result =  deposit.authors.any? do |person|
      person.full_name_naf_format == 'Eagle, Jane'
    end
    assert result, 'Author "Eagle, Jane" not found'
    result =  deposit.authors.any? do |person|
      person.full_name_naf_format == 'Par, John'
    end
    assert result, 'Author "Par, John" not found'
    result =  deposit.authors.any? do |person|
      person.full_name_naf_format == 'Holeinone, Golf'
    end
    assert result, 'Author "Holeinone, Golf" not found'
    result =  deposit.authors.any? do |person|
      person.full_name_naf_format == 'Albatross, Benedetto'
    end
    assert result, 'Author "Albatross, Benedetto" not found'
  end

  test "handle missing info" do
    content_dir = File.dirname(fixture_path_for('springer_nature_missing_info/mets.xml'))
    parser = Sword::Parsers::SpringerNatureParser.new
    deposit = parser.parse(content_dir, nil)
  end

  test "handle doi in the format 'https://doi.org/10.1186/s40248-018-0136-5'" do
    content_dir = File.dirname(fixture_path_for('springer_nature_doi_url_1/mets.xml'))
    parser = Sword::Parsers::SpringerNatureParser.new
    deposit = parser.parse(content_dir, nil)
    assert_equal '10.1186/s40248-018-0136-5', deposit.pub_doi
  end

  test "handle doi in the format 'http://dx.doi.org/10.1186/s12909-018-1155-9'" do
    content_dir = File.dirname(fixture_path_for('springer_nature_doi_url_2/mets.xml'))
    parser = Sword::Parsers::SpringerNatureParser.new
    deposit = parser.parse(content_dir, nil)
    assert_equal '10.1186/s12909-018-1155-9', deposit.pub_doi
  end

  test "handle doi in the format '10.1186/s40248-018-0136-5'" do
    content_dir = File.dirname(fixture_path_for('springer_nature_doi_url_1/mets.xml'))
    parser = Sword::Parsers::SpringerNatureParser.new
    deposit = parser.parse(content_dir, nil)
    assert_equal '10.1186/s40248-018-0136-5', deposit.pub_doi
  end
end
