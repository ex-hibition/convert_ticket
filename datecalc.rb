# -- 日付を計算するクラス

require 'bundler'
Bundler.require

require 'csv'
require 'holiday_japan'
require 'active_support/core_ext/time'

class DateCalculate
  attr_reader :exec_date,      # 処理日
              :first_date,     # 基準月(処理日翌月)の1日
              :last_date,      # 基準月(処理日翌月)の末日
              :format_yyyymmdd # 'yyyy/mm/dd' 0埋め無し

  # -- 通常は翌月1日を基準月とするが、引数'yyyymmdd'も渡せる
  def initialize(date: nil)
    @format_yyyymmdd = '%Y/%-m/%-d'
    date ||= Date.today.strftime(format_yyyymmdd)
    @exec_date  = Date.parse(date)
    @first_date = Date.parse(date).next_month.beginning_of_month
    @last_date  = Date.parse(date).next_month.end_of_month
  end

  # -- バージョン名を返す
  def get_version_name(condition: nil)
    if condition == 'ope'
      # -- 定例は翌月度
      first_date.strftime("運用　%Y年%m月度（定例）")
    else
      # -- 立会は当月度
      exec_date.strftime("月次　%Y年%m月度")
    end
  end

  # -- 基準月(処理日翌月)の月(01-12)を返す
  def get_month_mm
    first_date.strftime('%m')
  end

  # -- 基準月(処理日翌月)の指定日を返す
  def specific_date(dd:)
    Date.parse(first_date.strftime('%Y%m') + format("%02d", dd))
  end

  # -- 休日:true,平日:false
  def holiday?(date:)
    # -- 祝日ならtrue
    return true if HolidayJapan.check(date)
    # -- 休日ならtrue,それ以外はfalse
    return true if date.wday == 6 || date.wday == 0 ? true : false
  end

  # -- 指定日のx日後(デフォルト:処理日翌月の1日)
  def add_x_day(dd: nil, day:)
    dd ? date = specific_date(dd: dd) : date = first_date
    (date + day).strftime(format_yyyymmdd)
  end

  # -- 指定日のx日前(デフォルト:処理日翌月の末日)
  def sub_x_day(dd: nil, day:)
    dd ? date = specific_date(dd: dd) : date = last_date
    (date - day).strftime(format_yyyymmdd)
  end

  # -- 直近の営業日(デフォルト:処理日翌月の1日)
  def recent_next_business_day(dd: nil)
    dd ? date = specific_date(dd: dd) : date = first_date
    date += 1 while holiday?(date: date)
    date.strftime(format_yyyymmdd)
  end

  # -- 直近の営業日(デフォルト:処理日翌月の末日)
  def recent_prev_business_day(dd: nil)
    dd ? date = specific_date(dd: dd) : date = last_date
    date -= 1 while holiday?(date: date)
    date.strftime(format_yyyymmdd)
  end

  # -- 指定日のx営業日後(デフォルト:処理日翌月の1日)
  def add_x_business_day(dd: nil, day:)
    dd ? date = specific_date(dd: dd) : date = first_date
    # -- 指定日翌日からチェック
    date += 1
    
    (1..day).each do |i|
      if holiday?(date: date)
#        p "-- holiday #{i}, #{date}"
        date +=1
        redo
      else
#        p "-- business day #{i}, #{date}"
        date += 1 if i != day
      end
    end

    date.strftime(format_yyyymmdd)
  end

  # -- 指定日のx営業日前(デフォルト:処理日翌月の末日)
  def sub_x_business_day(dd: nil, day:)
    dd ? date = specific_date(dd: dd) : date = last_date
    # -- 指定日翌日からチェック
    date -= 1
    
    (1..day).each do |i|
      if holiday?(date: date)
#        p "-- holiday #{i}, #{date}"
        date -= 1
        redo
      else
#        p "-- business day #{i}, #{date}"
        date -= 1 if i != day
      end
    end

    date.strftime(format_yyyymmdd)
  end

  # -- 開始日／終了日を取得する
  def get_term(condition:)
      start_end = {};

      # チケット番号ごとに日付関連修正
      case condition
      # 1営業日から月末最終営業日まで
      when "this_month"
        start_end[:start] = recent_next_business_day
        start_end[:end]   = recent_prev_business_day

      # 1営業日から5営業日まで
      when "between_1st_biz_to_5th_biz"
        start_end[:start] = recent_next_business_day
        start_end[:end]   = add_x_business_day(day: 4)

      # 第6営業日(本締め翌日)
      when "on_6th_biz"
        start_end[:start] = add_x_business_day(day: 5)
        start_end[:end]   = add_x_business_day(day: 5)

      # 第6営業日(本締め翌日)から15日まで
      when "between_6th_biz_to_15th"
        start_end[:start] = add_x_business_day(day: 5)
        start_end[:end]   = add_x_day(day: 14)

      # 15日から月末3営業日前まで
      when "between_15th_to_last_3rd_biz"
        start_end[:start] = add_x_day(day: 14)
        start_end[:end]   = sub_x_business_day(day: 3)

      # 月末3営業日前から月末最終営業日まで
      when "last_3rd_biz"
        start_end[:start] = sub_x_business_day(day: 3)
        start_end[:end]   = recent_prev_business_day
      end

      start_end
  end

end
