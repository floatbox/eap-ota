# Временный security fix
ActionDispatch::ParamsParser::DEFAULT_PARSERS.delete(Mime::XML)
