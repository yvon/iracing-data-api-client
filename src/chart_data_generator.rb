class ChartDataGenerator
  SESSION_TYPES = {
    'Lone Qualifying' => 'qualifying',
    'Race' => 'race'
  }.freeze

  def initialize(content_generator)
    @content_generator = content_generator
    @mutex = Mutex.new
  end

  def generate(season, event, data)
    data['session_results'].each do |session|

      # Only races and qualifications
      session_type = SESSION_TYPES[session['simsession_type_name']]
      next unless session_type

      session['results'].each do |result|
        next unless selected_result?(result)
   
        path = [
          season['season_id'],
          result['car_class_id'],
          session_type
        ]

        append(path, data, result)
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

  def append(path, data, result)
    filename = "#{File.join(path.map(&:to_s))}.csv"

    content = [
      result['oldi_rating'],
      result['best_lap_time'],
      data['start_time'],
      result['display_name'],
      result['car_name']
    ]

    @mutex.synchronize do
      # TODO: safe csv generation
      @content_generator.generate(filename, content.join(',') + "\n", mode: 'a')
    end
  end
end
