require 'test/unit'
require 'ttml'

class Ttml::LineTest < Test::Unit::TestCase
  def test_new
    line = Ttml::Line.new
    assert_equal true, line.empty?
  end

  def test_time_str
    line = Ttml::Line.new
    line.start_time = 224.2
    line.end_time   = 244.578

    assert_equal "00:03:44,200 --> 00:04:04,578", line.time_str
  end

  def test_clean_text
    line = Ttml::Line.new(text: ["<p align=\"left\" ><font color=\"#ffa500\">Signori Consiglieri</font></p>"])
    assert_equal ["Signori Consiglieri"], line.cleaned_text
  end

end
