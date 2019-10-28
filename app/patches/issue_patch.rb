require_dependency 'issue'

module SerialNumberField
  module IssuePatch
    extend ActiveSupport::Concern
    unloadable

    included do
      unloadable

      before_save :on_before_save!
      before_create :on_before_create!
    end

    def on_before_save!
      serial_number_fields.each do |cf|
        next if assigned_serial_number?(cf)
        assign_serial_number!(cf)
      end
    end

    def on_before_create!
      serial_number_fields.each do |cf|
        next if !assigned_serial_number?(cf)
        assign_serial_number!(cf)
      end
    end

    def assign_serial_number!(cf)
        target_custom_value = serial_number_custom_value(cf)
        new_serial_number = cf.format.generate_value(cf, self)

        if target_custom_value.present?
          target_custom_value.value = new_serial_number
        end
    end

    def assigned_serial_number?(cf)
      serial_number_custom_value(cf).try(:value).present?
    end

    def serial_number_custom_value(cf)
      fields = available_custom_fields.map(&:id)
      index = fields.index(cf.id)
      return index ? custom_field_values[index]: nil
    end

    def serial_number_fields
      editable_custom_fields.select do |value|
        value.field_format == SerialNumberField::Format::NAME
      end
    end

  end
end

SerialNumberField::IssuePatch.tap do |mod|
  Issue.send :include, mod unless Issue.include?(mod)
end
