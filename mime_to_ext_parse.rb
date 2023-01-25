require 'csv'
require 'pp'

fp = File.open("lib/mime_to_extension.txt")
lines = fp.readlines


to_delete = []
lines.each_with_index do |line, index|
    if line[0] == '#'
        to_delete << index
    end
end

to_delete.each_with_index do |index, del_num|
    lines.delete_at(index - del_num)
end



mult_extension = []
lines.each_with_index do |line, index|
    line.each_char.with_index do |char, index|
        if char == "\t"
            line[index] = ","
            break
        end

        if index == (line.length - 1)
            raise "did not find a \\t even though all '#' lines are deleted. Line Error: #{line}"
        end
    end
    
    line.delete!("\t")

    line.each_char do |char|
        if char == " "
            mult_extension << index
            next
        end
    end
end

mult_extension.uniq!

def find_char(str, char_to_find)
    indexes = []

    str.each_char.with_index do |char, index|

        if char == char_to_find
            indexes << index
        end
    end

    return indexes
end

mult_extension.each do |line_index|
    line = lines[line_index]

    spaces = find_char(line, " ")
    comma = find_char(line, ",")[0]    

    start = comma + 1
    en = spaces[0]
    ext = line[start...en]

    starter = line[0..comma]
    
    lines.append(starter + ext + "\n")

    spaces.each_with_index do |space_ind, i|

        if i == spaces.length - 1
            start = spaces[i] + 1
            en = line.length - 1
            ext = line[start...en]
            
        else
            start = spaces[i] + 1
            en = spaces[i + 1]
            ext = line[start...en]
        end

        lines.append(starter + ext + "\n")
    end 
end

mult_extension.each_with_index do |index, del_num|
    lines.delete_at(index - del_num)
end

fp2 = File.open("lib/mime_to_ext.csv", "w")

fp2.write("mime,extension\n")

lines.each do |line|
    fp2.write(line)
end

pp lines