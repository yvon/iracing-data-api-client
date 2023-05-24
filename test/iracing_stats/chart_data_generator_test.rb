require 'test/unit'
require './lib/iracing_stats/chart_data_generator'

class ChartDataGeneratorTest < Test::Unit::TestCase
  def setup
    @chart_data_generator = IracingStats::ChartDataGenerator.new
  end

  def create_data(session_type)
    {
      'session_results' => [
        {
          'simsession_type_name' => session_type,
          'results' => [
            {
              'drop_race' => false,
              'class_interval' => 0,
              'best_lap_time' => 1200421,
              'oldi_rating' => 3973,
              'car_class_id' => 3283,
              'display_name' => 'Leon Hernandez',
              'car_name' => 'Radical SR10',
              'average_lap' => 1219025,
            },
          ],
        },
      ],
      'season_id' => 2023,
      'start_time' => '2023-05-24T00:00:00Z',
    }
  end

  def test_generate_with_race_session_type
    data = create_data('Race')
    @chart_data_generator.generate(data) do |keys, content|
      assert_equal('race', keys[:session_type])
    end
  end

  def test_generate_with_qualifying_session_type
    data = create_data('Lone Qualifying')
    @chart_data_generator.generate(data) do |keys, content|
      assert_equal('qualifying', keys[:session_type])
    end
  end

  def test_generate_with_other_session_type
    data = create_data('Practice')
    @chart_data_generator.generate(data) do |keys, content|
      raise "Block was not expected to be called for session type 'Practice'"
    end
  end

  def test_generate_content_values
    data = create_data('Race')
    @chart_data_generator.generate(data) do |keys, content|
      assert_equal(3973, content[0], "Expected oldi_rating to be 3973")
      assert_equal(1200421, content[1], "Expected best_lap_time to be 1200421")
      assert_equal('2023-05-24T00:00:00Z', content[2], "Expected start_time to match input data")
      assert_equal('Leon Hernandez', content[3], "Expected display_name to be 'Leon Hernandez'")
      assert_equal('Radical SR10', content[4], "Expected car_name to be 'Radical SR10'")
      assert_equal(1219025, content[5], "Expected average_lap to be 1219025")
    end
  end
end
