module FileManagerHelper
  def ocr_check(id)
    return '✅' if FileSet.find(id).extracted_text
    '❌'
  end
end
