require 'spec_helper'

describe DateCalculate do 
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

end