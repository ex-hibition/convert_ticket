require 'csv'
# -- 実際の処理はこちらに記載
require_relative 'datecalc'

file_name   = 'issues_tims_routine.csv'
INPUT_FILE  = "input/#{file_name}"
OUTPUT_FILE = "output/#{file_name}"

# -- 日付計算オブジェクト
term = DateCalculate.new

begin
  # -- 出力ファイルオープン
  CSV.open(OUTPUT_FILE, "w") do |output|
    # -- 入力ファイルオープン
    options = {encoding: 'UTF-8', headers: true}
    CSV.foreach(INPUT_FILE, options).with_index(1) do |row, i|
    # -- ヘッダ行出力
    output << row.headers if i == 1
  
      # -- 開始日／終了日取得
      start_end = term.get_term(condition: row["#"])
      # -- 月(01-12)取得
      month_mm = term.get_month_mm
      # -- バージョン名取得
      version_str = term.get_version_name(condition: 'ope')
    
      # -- チケットタイトルが対象月の場合のみ出力
      # -- 特定月のみ実施するチケットに対応
      next if row["題名"] !~ /^【毎月】|^【.*#{month_mm}月.*】/
        
      # -- csvファイル出力
      output << [ i,                   #row["#"],
                  row["プロジェクト"],
                  row["トラッカー"],
                  row["親チケット"],
                  row["ステータス"],
                  row["優先度"],
                  row["題名"],
                  row["作成者"],
                  row["担当者"],
                  row["更新日"],
                  row["カテゴリ"],
                  version_str,         #row["対象バージョン"],
                  start_end[:start],   #row["開始日"],
                  start_end[:end],     #row["期日"],
                  row["予定工数"],
                  row["合計予定工数"],
                  row["作業時間"],
                  row["合計作業時間"],
                  row["進捗率"],
                  row["作成日"],
                  row["終了日"],
                  row["最終更新者"],
                  row["関連するチケット"],
                  row["ファイル"],
                  row["優先度（数値）"],
                  row["共有設定"],
                  row["プライベート"],
                  row["説明"],
          ]
    end
  end
rescue StandardError => err
  p err
end
