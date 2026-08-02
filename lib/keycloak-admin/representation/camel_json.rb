# frozen_string_literal: true
module KeycloakAdmin
  module CamelJson

    def camelize(lower_case_and_underscored_word, first_letter_in_uppercase = true)
      word = lower_case_and_underscored_word.to_s
      if word.empty?
        word
      elsif first_letter_in_uppercase
        word.gsub(/\/(.?)/) { "::" + $1.upcase }.gsub(/(^|_)(.)/) { $2.upcase }
      else
        word[0] + camelize(word)[1..-1]
      end
    end
  end
end
