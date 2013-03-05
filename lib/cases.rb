# encoding: utf-8
module Cases

  def nominative
    name
  end

  def cases
    inflections = MorpherInflect.inflections( nominative )
    # попытка обойти странности склонений одушевленных объектов
    if nominative.present? && !nominative[/[ая]$/]
      inflections[3] = inflections[0]
    end
    inflections
  end

  def save_guessed
    inflections = cases
    pr = in_preposition(self.name)
    update_attributes(:morpher_to => "#{pr} #{(cases[3]).chomp}", :morpher_from => "из #{(cases[1]).chomp}", :morpher_in => "#{pr} #{(cases[5]).chomp}" ) if cases[3].presence && cases[5].presence && cases[1].presence && cases.uniq.length > 1
  end

  def in_preposition word
    if (word.mb_chars.split('')[0..1].every.to_s - "бвгджзйклмнпрстфхцчшщБВГДЖЗЙКЛМНПРСТФХЦЧШЩ".mb_chars.split('').every.to_s == []) && ("ВФвф".mb_chars.split('').every.to_s.include? word.mb_chars[0].to_s) && !(("БВГДЖЗЙКЛМНПРСТФХЦЧШЩ".mb_chars.split('').every.to_s.include? word.mb_chars[1].to_s))
      'во'
    else
      'в'
    end
  end


  def case_to
    proper_to.presence || morpher_to.presence || 'в ' + nominative
  end

  def case_from
    proper_from.presence || morpher_from.presence || 'из ' + nominative
  end

  def case_in
    proper_in.presence || morpher_in.presence || 'в ' + nominative
  end

  def case_to=(str)
    if str.present? && str != guessed_to
      self.proper_to = str
    else
      self.proper_to = nil
    end
  end

  def case_from=(str)
    if str.present? && str != guessed_from
      self.proper_from = str
    else
      self.proper_from = nil
    end
  end

  def case_in=(str)
    if str.present? && str != guessed_in
      self.proper_in = str
    else
      self.proper_in = nil
    end
  end

end
