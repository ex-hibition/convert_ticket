require 'spec_helper'

describe DateCalculate do 
  # -- 20180215を引数にオブジェクト生成、基準月は'201803'
  let(:term) { DateCalculate.new(params) }
  let(:params) { { date: '20180215' } }

  describe '#get_version_name' do
    context '定例運用タスクの場合' do
      subject { term.get_version_name(condition: 'ope') }
      it '翌月でバージョン名を生成する' do
        is_expected.to eq '運用　2018年03月度（定例）'
      end
    end
    context '月次立会いタスクの場合' do
      subject { term.get_version_name }
      it '当月でバージョン名を生成する' do
        is_expected.to eq '月次　2018年02月度'
      end
    end
  end

  describe '#get_month_mm' do
    subject { term.get_month_mm }
    it '0埋めした月(01-12)を生成する' do
      is_expected.to eq '03'
    end
  end

  describe '#specific_date' do
    subject { term.specific_date(dd: '10') }
    it '基準月の指定日を生成する' do
      is_expected.to eq Date.parse('20180310')
    end
  end

  describe '#holiday?' do
    subject { term.holiday?(date: Date.parse(date)) }
    context '祝日(振替休日)の場合' do
      let(:date) { '20180212' }
      it 'true を返す' do
        is_expected.to be_truthy 
      end
    end
    context '休日の場合' do
      let(:date) { '20180217' }
      it 'true を返す' do
        is_expected.to be_truthy 
      end
    end
    context '平日の場合' do
      let(:date) { '20180216' }
      it 'false を返す' do
        is_expected.to be_falsey 
      end
    end
  end

  describe '#add_x_day' do
    context '3日後を指定した場合' do
      subject { term.add_x_day(day: day) }
      let(:day) { 3 }
      it '基準月の1日の3日後を生成する' do
        is_expected.to eq '2018/3/4'
      end
    end
    context '指定日の3日後を指定した場合' do
      subject { term.add_x_day(dd: dd, day: day) }
      let(:dd) { '03' }
      let(:day) { 3 }
      it '基準月の指定日の3日後を生成する' do
        is_expected.to eq '2018/3/6'
      end
    end
  end

  describe '#sub_x_day' do
    let(:day) { 3 }
    context '3日前を指定した場合' do
      subject { term.sub_x_day(day: day) }
      it '基準月末日の3日前を生成する' do
        is_expected.to eq '2018/3/28'
      end
    end
    context '指定日の3日前を指定した場合' do
      subject { term.sub_x_day(dd: dd, day: day) }
      let(:dd) { '15' }
      it '基準月の指定日の3日前を生成する' do
        is_expected.to eq '2018/3/12'
      end
    end
  end

  describe '#recent_next_business_day' do
    context '引数なしの場合' do
      subject { term.recent_next_business_day }
      it '基準月の1日から数えて直近の営業日を生成する' do
        is_expected.to eq '2018/3/1'
      end
    end
    context '3日を指定した場合' do
      subject { term.recent_next_business_day(dd: dd) }
      let(:dd) { '03' }
      it '基準月の指定日から数えて直近の営業日を生成する' do
        is_expected.to eq '2018/3/5'
      end
    end
  end

  describe '#recent_prev_business_day' do
    context '引数なしの場合' do
      subject { term.recent_prev_business_day }
      it '基準月末日から遡って直近の営業日を生成する' do
        is_expected.to eq '2018/3/30'
      end
    end
    context '3日を指定した場合' do
      subject { term.recent_prev_business_day(dd: dd) }
      let(:dd) { 3 }
      it '基準月の指定日から遡って直近の営業日を生成する' do
        is_expected.to eq '2018/3/2'
      end
    end
  end

  describe '#add_x_business_day' do
    let(:day) { 3 }
    context '3営業日後を指定した場合' do
      subject { term.add_x_business_day(day: day) }
      it '基準月の1日から数えて3営業日後を生成する' do
        is_expected.to eq '2018/3/6'
      end
    end
    context '基準月の指定日の3営業日後を指定した場合' do
      subject { term.add_x_business_day(dd: dd, day: day) }
      let(:dd) { 15 }
      it '基準月の指定日から数えて3営業日後を生成する' do
        is_expected.to eq '2018/3/20'
      end
    end
  end

  describe '#sub_x_business_day' do
    let(:day) { 3 }
    context '3営業日前を指定した場合' do
      subject { term.sub_x_business_day(day: day) }
      it '基準月の1日から数えて3営業日前を生成する' do
        is_expected.to eq '2018/3/28'
      end
    end
    context '基準月の指定日の3営業日前を指定した場合' do
      subject { term.sub_x_business_day(dd: dd, day: day) }
      let(:dd) { 15 }
      it '基準月の指定日から数えて3営業日前を生成する' do
        is_expected.to eq '2018/3/12'
      end
    end
  end

  describe '#get_term' do
    subject { term.get_term(condition: condition) }
    context '当月中(this_month)を指定した場合' do
      let(:condition) { 'this_month' }
      it '基準月の1営業日から月末最終日を生成する' do
        is_expected.to match( :start => '2018/3/1', :end => '2018/3/30' ) 
      end
    end
    context '1営業日から5営業日(between_1st_biz_to_5th_biz)を指定した場合' do
      let(:condition) { 'between_1st_biz_to_5th_biz' }
      it '基準月の1営業日から5営業日を生成する' do
        is_expected.to match( :start => '2018/3/1', :end => '2018/3/7' ) 
      end
    end
    context '3日から5営業日(between_3rd_to_5th_biz)を指定した場合' do
      let(:condition) { 'between_3rd_to_5th_biz' }
      it '基準月の3日から5営業日を生成する' do
        is_expected.to match( :start => '2018/3/3', :end => '2018/3/7' ) 
      end
    end
    context '5営業日(on_6th_biz)を指定した場合' do
      let(:condition) { 'on_6th_biz' }
      it '基準月の6営業日を生成する' do
        is_expected.to match( :start => '2018/3/8', :end => '2018/3/8' ) 
      end
    end
    context '6営業日から10日(between_6th_biz_to_10th)を指定した場合' do
      let(:condition) { 'between_6th_biz_to_10th' }
      it '基準月の6営業日から10日を生成する' do
        is_expected.to match( :start => '2018/3/8', :end => '2018/3/10' ) 
      end
    end
    context '6営業日から15日(between_6th_biz_to_15th)を指定した場合' do
      let(:condition) { 'between_6th_biz_to_15th' }
      it '基準月の6営業日から15日を生成する' do
        is_expected.to match( :start => '2018/3/8', :end => '2018/3/15' ) 
      end
    end
    context '15日から月末3営業日(between_15th_to_last_3rd_biz)を指定した場合' do
      let(:condition) { 'between_15th_to_last_3rd_biz' }
      it '基準月の15日から月末3営業日を生成する' do
        is_expected.to match( :start => '2018/3/15', :end => '2018/3/28' ) 
      end
    end
    context '月末3営業日から最終営業日(last_3rd_biz)を指定した場合' do
      let(:condition) { 'last_3rd_biz' }
      it '基準月の月末3営業日から最終営業日を生成する' do
        is_expected.to match( :start => '2018/3/28', :end => '2018/3/30' ) 
      end
    end
  end

end