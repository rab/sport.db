# encoding: utf-8

###
#  to run use
#     ruby -I ./lib -I ./test test/test_wiki_reader.rb


require 'helper'

class TestWikiReader < MiniTest::Test

  def test_parse_at
    recs = SportDb::Import::WikiReader.parse( <<TXT )
===================================
=  Albania (al)

FK Partizani Tirana
KF Tirana
FK Kukësi
KF Laçi
TXT

    pp recs

    assert_equal 4, recs.size
    assert_equal 'FK Partizani Tirana', recs[0].name
    assert_equal 'Albania',             recs[0].country.name
    assert_equal 'al',                  recs[0].country.key
  end


  def test_parse_be
    recs = SportDb::Import::WikiReader.parse( <<TXT )
===========================
= Belgium (be)

R.S.C._Anderlecht
Royal_Antwerp_F.C.
Cercle_Brugge_K.S.V.
R._Charleroi_S.C.
Club_Brugge_KV
TXT

    pp recs

    assert_equal 5, recs.size
    assert_equal 'R.S.C. Anderlecht',  recs[0].name
    assert_equal 'Belgium',            recs[0].country.name
    assert_equal 'be',                 recs[0].country.key
  end

  def test_parse_world
    recs = SportDb::Import::WikiReader.parse( <<TXT )
= Albania (al) =

FK Partizani Tirana


= Belgium (be) =

# some comments here
R.S.C._Anderlecht     # some end-of-line comments here
TXT

    pp recs

    assert_equal 2, recs.size
    assert_equal 'FK Partizani Tirana', recs[0].name
    assert_equal 'Albania',             recs[0].country.name
    assert_equal 'al',                  recs[0].country.key

    assert_equal 'R.S.C. Anderlecht',  recs[1].name
    assert_equal 'Belgium',            recs[1].country.name
    assert_equal 'be',                 recs[1].country.key
  end

end # class TestWikiReader
