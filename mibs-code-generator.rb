require 'yaml'

puts <<eof
package org.inuua.snmp.types.helpers;
// This class is autogenerated from yaml files
import java.util.TreeMap;
import java.util.Arrays;
import java.util.List;
import java.util.regex.Pattern;
import org.inuua.util.ListHelpers;

public final class SnmpObjectIdentifierNameHumanizer {
    public static String humanize(String oid) {
        if (m == null) {
            initializeTheMap();
        }

        List<String> partList = Arrays.asList(oid.split(Pattern.quote(".")));

        String ret;
        for (int len = partList.size(); len > 0; len--) {
            ret = m.get(ListHelpers.implode(partList.subList(0, len), "."));
            if (ret != null) {
                if (len == partList.size()) {
                    return ret;
                } else {
                    return ret + "." + ListHelpers.implode(partList.subList(len, partList.size()), ".");
                }
            }
        }
        return oid;
    }
eof

complete_mib_list = {}
for file in ARGV
	mibs = []
	YAML::load_documents(File.open(file)){ |mib| mibs << mib }

	mibs.each do |e|
		e.each do |k,v|
			complete_mib_list[v.strip] = k.strip
		end
	end
end

counter = 0
functions_to_call = []
puts "private static void function#{counter}() {"
complete_mib_list.each do |k, v|
  counter += 1
  if counter.modulo(1000) == 0
    puts " } "
    puts "private static void function#{counter}() {"
    functions_to_call << "function#{counter}"
  end
  puts " m.put(\"#{k}\", \"#{v}\");"
end
puts "}"
puts "private static void initializeTheMap() {"
puts "m = new TreeMap<String, String>();"
puts "function0();"
for f in functions_to_call
  puts "#{f}();"
end
puts "};"
puts "private static TreeMap<String, String> m = null;"
puts "}"

