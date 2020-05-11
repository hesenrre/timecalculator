require 'timecalculator/calculator'
RSpec.describe Timecalculator::Calculator do
  it 'identifies if it is a weekend' do
    calculator = Timecalculator::Calculator.new
    expect(calculator.weekend?(Date.parse('09-05-2020'))).to be_truthy
  end

  it 'identifies if it is a week day' do
    calculator = Timecalculator::Calculator.new
    expect(calculator.weekend?(Date.parse('08-05-2020'))).to be_falsy
  end

  it 'identifies if holiday' do
    calculator = Timecalculator::Calculator.new(holidays: [Date.parse('30-01-2020')])
    expect(calculator.holiday?(Date.parse('30-01-2020'))).to be_truthy
  end

  it 'identifies if working day' do
    working_day = Date.parse('07-05-2020')
    non_working_day1 = Date.parse('09-04-2020')
    non_working_day2 = Date.parse('10-05-2020')
    holidays = [Date.parse('01-01-2020'), Date.parse('09-04-2020'), Date.parse('10-04-2020'), Date.parse('10-05-2020')]

    calculator = Timecalculator::Calculator.new(holidays: holidays)
    expect(calculator.working_day?(working_day)).to be_truthy
    expect(calculator.working_day?(non_working_day1)).to be_falsy
    expect(calculator.working_day?(non_working_day2)).to be_falsy
  end

  it 'identifies natural days' do
    day1 = Date.parse('01-05-2020')
    day2 = Date.parse('09-05-2020')
    calculator = Timecalculator::Calculator.new
    expect(calculator.days_between_dates(day1, day2).count).to eq(8)
  end

  it 'identifies 9 working days' do
    day1 = Date.parse('24-04-2020')
    day2 = Date.parse('09-05-2020')
    holidays = [Date.parse('01-05-2020')]
    calculator = Timecalculator::Calculator.new(holidays: holidays)
    expect(calculator.working_days_between_dates(day1, day2).count).to eq(9)
  end

  it 'identifies 1 working days' do
    day1 = Date.parse('07-05-2020')
    day2 = Date.parse('11-05-2020')
    calculator = Timecalculator::Calculator.new
    expect(calculator.working_days_between_dates(day1, day2).count).to eq(1)
  end

  it 'identifies 1440 minutes of working week' do
    day1 = Date.parse('04-05-2020')
    day2 = Date.parse('08-05-2020')
    calculator = Timecalculator::Calculator.new
    expect(calculator.full_day_minutes_between_dates(day1, day2)).to eq(1440)
  end

  it 'identifies 45 minutes between 10:30 - 11:15' do
    calculator = Timecalculator::Calculator.new
    expect(calculator.minutes_between_two_times({ h: 11, m: 15 }, { h: 10, m: 30 })).to eq(45)
    expect(calculator.minutes_between_two_times({ h: 10, m: 30 }, { h: 11, m: 15 })).to eq(45)
  end

  it 'identifies 480 minutes between 9:00 - 18:00' do
    calculator = Timecalculator::Calculator.new
    expect(calculator.working_minutes_between_to_times({ h: 9 }, { h: 18 })).to eq(480)
  end

  it 'identifies 2400 minutes between 27/04/2020 9:00 - 01/05/2020 18:00 without holliday' do
    calculator = Timecalculator::Calculator.new
    expect(calculator.working_minutes_between_to_datetimes(DateTime.parse('2020-04-27 09:00'), DateTime.parse('2020-05-01 18:00'))).to eq(2400)
  end

  it 'identifies 1920 minutes between 27/04/2020 9:00 - 01/05/2020 18:00 with holliday' do
    calculator = Timecalculator::Calculator.new(holidays: [Date.parse('01-05-2020')])
    expect(calculator.working_minutes_between_to_datetimes(DateTime.parse('2020-04-27 09:00'), DateTime.parse('2020-05-01 18:00'))).to eq(1920)
  end

  it 'identifies 1920 minutes between 01/05/2020 9:00 - 07/05/2020 18:00 with holliday' do
    calculator = Timecalculator::Calculator.new(holidays: [Date.parse('01-05-2020')])
    expect(calculator.working_minutes_between_to_datetimes(DateTime.parse('2020-05-01 09:00'), DateTime.parse('2020-05-07 18:00'))).to eq(1920)
  end

  it 'identifies 2400 minutes between 27/04/2020 9:00 - 04/05/2020 18:00 with holliday' do
    calculator = Timecalculator::Calculator.new(holidays: [Date.parse('01-05-2020')])
    expect(calculator.working_minutes_between_to_datetimes(DateTime.parse('2020-04-27 09:00'), DateTime.parse('2020-05-04 18:00'))).to eq(2400)
  end

  it 'identifies 2400 minutes between 27/04/2020 9:00 - 04/05/2020 18:00 strings in batch with holliday' do
    calculator = Timecalculator::Calculator.new(holidays: [Date.parse('01-05-2020')])
    expect(calculator.batch_working_minutes_between_to_datetimes([['2020-04-27 09:00', '2020-05-04 18:00']])).to eq(2400)
  end
end
