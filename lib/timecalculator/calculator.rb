# frozen_string_literal: true

module Timecalculator
  class Calculator
    # def initialize(day_hour_begin = 9, day_hour_end = 18, lunch_time=13, holidays = [])
    def initialize(**options)
      @day_hour_begin = options.fetch(:day_hour_begin, 9)
      @day_hour_end = options.fetch(:day_hour_end, 18)
      @lunch_time = options.fetch(:lunch_time, [13])
      @holidays = options.fetch(:holidays, []).reject { |e| e.to_s.empty? }.map(&:to_date)
    end

    def batch_working_minutes_between_to_datetimes(dates = [])
      dates.reduce(0) do |sum, batch|
        sum + working_minutes_between_to_datetimes(DateTime.parse(batch.first), DateTime.parse(batch.last))
      end
    end

    def working_minutes_between_to_datetimes(dt1, dt2)
      if dt1.to_date == dt2.to_date
        working_minutes_between_to_times({ h: dt1.hour, m: dt1.minute }, { h: dt2.hour, m: dt2.minute })
      elsif dt1 < dt2
        full_day_minutes_between_dates_with_boundaries(dt1, dt2)
      else
        full_day_minutes_between_dates_with_boundaries(dt2, dt1)
      end
    end

    def full_day_minutes_between_dates_with_boundaries(dt1, dt2)
      minutes = 0
      unless holiday?(dt1) || dt1.hour >= @day_hour_end
        minutes += working_minutes_between_to_times({ h: dt1.hour, m: dt1.minute }, { h: @day_hour_end })
      end
      minutes += full_day_minutes_between_dates(dt1, dt2)
      minutes += working_minutes_between_to_times({ h: @day_hour_begin }, { h: dt2.hour, m: dt2.minute }) unless holiday?(dt2)
      minutes
    end

    def full_day_minutes_between_dates(date1, date2)
      working_days_between_dates(date1, date2).count * full_day_minutes
    end

    def working_minutes_between_to_times(time1, time2)
      sorted_times = min_max_time(time1, time2)
      start_time = start_time(sorted_times[:min])
      ending_time = ending_time(sorted_times[:max])
      offset = minutes_between_two_times(start_time, ending_time)
      offset - lunch_time(start_time[:h], ending_time[:h])
    end

    def datetime_from_date_and_time(date, hour)
      DateTime.new(date.year, date.month, date.day, hour, 0, 0, now.zone)
    end

    def lunch_time(time1, time2)
      time_range = (time1...time2)
      @lunch_time.reduce(0) { |sum, lunch_time| sum + (time_range.cover?(lunch_time) ? 60 : 0) }
    end

    def start_time(date_time)
      hour = date_time.fetch(:h, 0)
      minute = date_time.fetch(:m, 0)
      if @lunch_time.include?(hour)
        hour, minute = hour + 1, 0
      elsif hour < @day_hour_begin
        hour, minute = @day_hour_begin, 0
      end
      { h: hour, m: minute }
    end

    def ending_time(date_time)
      hour = date_time.fetch(:h, 0)
      minute = date_time.fetch(:m, 0)
      if hour == @lunch_time.include?(hour)
        minute = 0
      elsif hour >= @day_hour_end
        hour, minute = @day_hour_end, 0
      end
      { h: hour, m: minute }
    end

    def working_days_between_dates(date1, date2)
      days_between_dates(date1 + 1, date2).filter { |date| working_day?(date) }
    end

    def full_day_minutes
      @full_day_minutes ||= (@day_hour_end - @day_hour_begin - @lunch_time.count) * 60
    end

    def minutes_between_two_times(time1 = {}, time2 = {})
      sorted_times = min_max_time(time1, time2)
      max_h = sorted_times[:max].fetch(:h, 0)
      min_h = sorted_times[:min].fetch(:h, 0)
      max_m = sorted_times[:max].fetch(:m, 0)
      min_m = sorted_times[:min].fetch(:m, 0)
      ((max_h - min_h) * 60) + (max_m - min_m)
    end

    def min_max_time(time1 = {}, time2 = {})
      if time1.fetch(:h, 0) == time2.fetch(:h, 0)
        { min: time1.fetch(:m, 0) < time2.fetch(:m, 0) ? time1 : time2,
          max: time1.fetch(:m, 0) > time2.fetch(:m, 0) ? time1 : time2 }
      else
        { min: time1.fetch(:h, 0) < time2.fetch(:h, 0) ? time1 : time2,
          max: time1.fetch(:h, 0) > time2.fetch(:h, 0) ? time1 : time2 }
      end
    end

    def days_between_dates(date1, date2)
      (date1.to_date...date2.to_date)
    end

    def weekdays
      @weekdays ||= [0, 6]
    end

    def weekend?(date)
      return false unless date

      weekdays.include?(date.wday)
    end

    def holiday?(date)
      return false unless date

      @holidays.include?(date.to_date)
    end

    def working_day?(date)
      !(weekend?(date) || holiday?(date))
    end
  end
end
