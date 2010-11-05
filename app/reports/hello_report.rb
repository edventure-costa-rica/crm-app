class HelloReport < Prawn::Document
    def to_pdf
        text "Hello, PDF world"
        
        render
    end
end
