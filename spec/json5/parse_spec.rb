require 'spec_helper'

describe JSON5 do
  def parseJSON5
    JSON5.parse(@str)
  end

  def parseJSON
    Oj.load(@str)
  end

  def parseES5
    js = V8::Context.new.eval("\"use strict\"; (\n" + @str + "\n)")
    unify(js)
  end

  def unify obj
    case obj
    when V8::Array
      unify(obj.to_a)
    when V8::Object
      unify(obj.to_h)
    when Hash
      obj.map{ |k, v| [k, unify(v)] }.to_h
    when Array
      obj.map{ |v| unify(v) }
    else
      obj
    end
  end

  Dir[File.expand_path('../../parse-cases/**/*.*', __FILE__)].each do |path|
    filename = File.basename(path)
    context "#{filename}" do
      before do
        @str = File.read(path, encoding: 'UTF-8')
      end

      case File.extname(path)
      when '.json'
        it "Expected parsed JSON5 to equal parsed JSON" do
          expect(parseJSON5).to eq(parseJSON)
        end
      when '.json5'
        it 'Expected parsed JSON5 to equal parsed ES5.' do
          if filename == 'nan.json5'
            expect(parseJSON5.nan?).to eq(parseES5.nan?)
          else
            expect(parseJSON5).to eq(parseES5)
          end
        end
      when '.js'
        it 'Test case bug expected ES5 parsing not to fail.' do
          expect{ parseES5 }.not_to raise_exception
        end

        it 'Expected JSON5 parsing to fail.' do
          expect{ parseJSON5 }.to raise_exception
        end
      when '.txt'
        it 'Test case bug: expected ES5 parsing to fail.' do
          expect{ parseES5 }.to raise_exception
        end

        it 'Expected JSON5 parsing to fail.' do
          expect{ parseJSON5 }.to raise_exception
        end
      end
    end
  end
end
