module IracingStats
  class ChartDataGenerator
    SESSION_TYPES = {
      'Lone Qualifying' => 'qualifying',
      'Race' => 'race'
    }.freeze

    def generate(data, &block)
      data['session_results'].each do |session|
        # Only races and qualifications
        session_type = SESSION_TYPES[session['simsession_type_name']]
        next unless session_type

        session['results'].each do |result|
          next unless selected_result?(result)

          car_class_id = result['car_class_id']

          keys = {
            season_id: data['season_id'],
            car_class_id: car_class_id,
            session_type: session_type
          }

          content = [
            result['oldi_rating'],
            result['best_lap_time'],
            data['start_time'],
            result['display_name'],
            result['car_name'],
            result['average_lap']
          ]

          block.call(keys, content)
        end
      end
    end

    private

    def selected_result?(result)
      # Members who finished the race
      return false if result['drop_race'] == true

      # Under the winner lap
      return false if result['class_interval'] < 0

      # With lap times (I have -1 values)
      return false if result['best_lap_time'] <= 0

      # With irating (I have -1 values, rookies?)
      return false if result['oldi_rating'] <= 0

      true
    end
  end
end
