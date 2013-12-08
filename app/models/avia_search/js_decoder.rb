# используется в pricer/validate
class AviaSearch::JsDecoder

  def decode(params_raw)
    params_raw = HashWithIndifferentAccess.new(params_raw)
    people_count = params_raw[:people_count]
    params = params_raw.merge(people_count) if people_count
    params.except!(:people_count)
    segments = params[:segments] ? params[:segments].values : []
    params[:segments] = segments.map do |segment|
      segment[:from] = Completer.object_from_string(segment[:from])
      segment[:to] = Completer.object_from_string(segment[:to])
      segment
    end
    AviaSearch.new(params)
  end

end
