require 'test/unit'
require 'ttml'

class DocumentTest < Test::Unit::TestCase

  def setup
    @doc = TTML::Document.new(File.join(File.dirname(__FILE__), 'fixtures', 'sample.xml'))
  end

  def test_class
    assert @doc.is_a?(TTML::Document)
  end

  def test_copyright
    assert_equal '2012 (c) loop', @doc.copyright
  end

  def test_title
    assert_equal 'Timed Text DFPX', @doc.title
  end

  def test_subs_no_param
    assert @doc.subtitle_stream.is_a?(Array)
  end

  def test_subs_start_param
    assert @doc.subtitle_stream(99999999.0).empty?
    assert_equal 1, @doc.subtitle_stream(746.0).size
  end

  def test_subs_end_param
    assert @doc.subtitle_stream(0.0, 0.0).empty?
    assert_equal 1, @doc.subtitle_stream(746.63, 749.38).size
  end

  def test_other_file
    # (with different namespaces)
    doc = TTML::Document.new(File.join(File.dirname(__FILE__), 'fixtures', 'sample_2.xml'))
    assert_equal 'Timed Text DFPX', doc.title
    assert @doc.subtitle_stream.is_a?(Array)
  end

  def test_parse_stream
    assert_equal @doc, @doc.parse_document
    assert_equal 31, @doc.lines.length
    assert_equal 0, @doc.errors.length
  end

  def test_parse
    doc = TTML::Document.parse(File.join(File.dirname(__FILE__), 'fixtures', 'sample.xml'))
    assert_equal 31, doc.lines.length
    assert_equal 1, doc.lines.first.sequence
    assert_equal 31, doc.lines.last.sequence
    assert_equal 358.72, doc.lines.first.start_time
    assert_equal 362.5, doc.lines.first.end_time
    assert_equal ["<p align=\"left\" ><font color=\"#ffa500\">Signori Consiglieri siete pregati di prendere posto</font></p>"], doc.lines.first.text
  end

end
