module HasSynonyms
  def synonyms
    synonym_list.present? ? synonym_list.split(',').every.strip : []
  end

  def synonyms=(words)
    self.synonym_list = words.join(', ')
  end
end
