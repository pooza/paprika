module Paprika
  class TagSearchContract < Contract
    params do
      required(:q).value(:string)
    end
  end
end
