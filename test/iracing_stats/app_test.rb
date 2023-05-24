require 'test/unit'
require 'tempfile'
require './lib/iracing_stats/app'

class TestApp < Test::Unit::TestCase
  INPUT_FIXTURES_DIRECTORY = './test/fixtures/data/'
  EXPECTED_OUTPUT_DIRECTORY = './test/fixtures/expected_output/'
  OUTPUT_DIRECTORY = Dir.tmpdir

  def setup
    @app = IracingStats::App.new
  end

  def test_generate_chart_content
    test_data_file = INPUT_FIXTURES_DIRECTORY + 'results/get?subsession_id=61532299'
    expected_output_file = EXPECTED_OUTPUT_DIRECTORY + 'chart.csv'
    generated_file = Tempfile.new

    # Call the method under test
    @app.generate_chart_content(generated_file.path, [test_data_file])

    # Check if the output file is created in the output directory
    assert(File.exist?(generated_file.path), "Expected output file to exist")

    # Compare the actual and expected output
    expected_output = File.read(expected_output_file)
    actual_output = File.read(generated_file)
    assert_equal(expected_output, actual_output, "Output did not match expected output")
  end
end
