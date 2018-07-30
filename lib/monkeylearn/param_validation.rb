def validate_order_by_param(order_by_param)
  def validate_order_by_param_field(field_string)
    if field_string .include? ','
      raise MonkeylearnError, "Invalid ',' (comma) character found in 'order_by' fieldname '#{field_string}', try sending a list of strings if you need to specify multiple fields"
    elsif field_string !~ /^-?[a-z_]+$/
      raise MonkeylearnError, "Invalid characters found in 'order_by fieldname '#{field_string}'"
    end
    field_string
  end

  order_by = []
  if order_by_param.is_a? String
    order_by.push(validate_order_by_param_field(order_by_param))
  elsif order_by_param.respond_to? 'each'
    if order_by_param.length < 1
      raise MonkeylearnError, "'order_by' parameter must be a non empty list of strings, an empty list was found"
    end
    seen_fields = {}
    order_by_param.each do |order_by_field|
      field_name = order_by_field
      if field_name[0] == '-'
        field_name = field_name[1..-1]
      end
      if seen_fields.key? field_name
        raise MonkeylearnError, "'order_by' parameter must be a list unique field names, duplicated fields where found: '#{field_name}'."
      end
      seen_fields[field_name] = true

      order_by.push(validate_order_by_param_field(order_by_field))
    end
    order_by
  else
    raise MonkeylearnError, "'order_by' param must be a string or a list of strings"
  end

  return order_by.join(',')
end
