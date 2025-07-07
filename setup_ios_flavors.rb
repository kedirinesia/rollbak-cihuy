# setup_ios_flavors.rb
require 'xcodeproj'
require 'fileutils'

# --- Konfigurasi ---
# Path ke file-file penting relatif dari direktori root proyek
android_gradle_file = 'android/app/build.gradle'
ios_project_path = 'ios/Runner.xcodeproj'
ios_info_plist_path = 'ios/Runner/Info.plist'
configs_dir = 'ios/Flutter/Configurations'
# -------------------

def parse_flavors(gradle_file)
  flavors = {}
  content = File.read(gradle_file)
  
  # Regex untuk menangkap blok productFlavors
  product_flavors_block = content[/productFlavors\s*\{([\s\S]*?)\n\s*\}/, 1]
  
  unless product_flavors_block
    puts "Error: Blok productFlavors tidak ditemukan di #{gradle_file}"
    return flavors
  end

  # Regex untuk menangkap setiap flavor dan applicationId-nya
  product_flavors_block.scan(/(\w+)\s*\{[^}]+?applicationId\s+"([^"]+)"[^}]+\}/) do |match|
    flavor_name = match[0]
    app_id = match[1]
    flavors[flavor_name] = app_id
  end

  puts "Menemukan #{flavors.length} flavor."
  flavors
end

def create_xcconfig_files(flavors, configs_dir)
  puts "Membuat direktori untuk file .xcconfig di: #{configs_dir}"
  FileUtils.mkdir_p(configs_dir)

  flavors.each do |name, app_id|
    config_path = File.join(configs_dir, "#{name}.xcconfig")
    display_name = name.capitalize
    # Asumsi entry point adalah lib/main_FLAVORNAME.dart
    # Jika Anda menggunakan satu main.dart, hapus baris FLUTTER_TARGET
    content = <<-XCCONFIG
#include "Generated.xcconfig"

// Konfigurasi untuk flavor: #{name}
PRODUCT_BUNDLE_IDENTIFIER = #{app_id}
APP_DISPLAY_NAME = #{display_name}
FLUTTER_TARGET = lib/main_#{name}.dart
    XCCONFIG

    File.write(config_path, content)
    puts "  -> Membuat #{config_path}"
  end
end

def update_xcode_project(project_path, flavors, configs_dir)
  puts "Membuka proyek Xcode: #{project_path}"
  project = Xcodeproj::Project.open(project_path)
  target = project.targets.find { |t| t.name == 'Runner' }
  
  unless target
      puts "Error: Target 'Runner' tidak ditemukan di proyek Xcode."
      return
  end

  # Tambahkan grup 'Configurations' ke proyek jika belum ada
  config_group = project.main_group.find_subpath('Flutter/Configurations', true)
  config_group.clear
  config_group.set_source_tree('<group>')

  flavors.each_key do |name|
    # Tambahkan file .xcconfig ke grup di Xcode
    config_file_ref = config_group.new_file(File.join(configs_dir.gsub('ios/', ''), "#{name}.xcconfig"))

    # Buat Build Configurations baru (Debug, Profile, Release) untuk setiap flavor
    ['Debug', 'Profile', 'Release'].each do |config_name|
      new_config_name = "#{config_name}-#{name}"
      
      # Duplikasi dari konfigurasi yang sudah ada
      build_config = target.build_configurations.find { |c| c.name == config_name }
      new_build_config = project.new(Xcodeproj::Project::Object::XCBuildConfiguration)
      new_build_config.name = new_config_name
      new_build_config.base_configuration_reference = config_file_ref
      new_build_config.build_settings = build_config.build_settings.clone
      target.build_configuration_list.build_configurations << new_build_config
    end
    puts "  -> Membuat Build Configurations untuk flavor '#{name}'"
  end
  
  project.save
  puts "Proyek Xcode berhasil diperbarui dengan Build Configurations baru."
end

def create_schemes(project_path, flavors)
    puts "Membuat Schemes untuk setiap flavor..."
    project = Xcodeproj::Project.open(project_path)
    
    flavors.each_key do |name|
        # Duplikasi dari scheme 'Runner' yang sudah ada
        shared_data_dir = Xcodeproj::XCScheme.shared_data_dir(project.path)
        runner_scheme_path = File.join(shared_data_dir, 'Runner.xcscheme')
        
        unless File.exist?(runner_scheme_path)
            puts "Warning: Scheme 'Runner' tidak ditemukan. Membuat scheme baru dari awal."
            scheme = Xcodeproj::XCScheme.new
        else
            scheme = Xcodeproj::XCScheme.new(runner_scheme_path)
        end

        scheme.name = name
        
        # Konfigurasi Build Action
        scheme.launch_action.build_configuration = "Debug-#{name}"
        scheme.profile_action.build_configuration = "Profile-#{name}"
        scheme.analyze_action.build_configuration = "Debug-#{name}"
        scheme.archive_action.build_configuration = "Release-#{name}"
        
        scheme.save_as(project.path, name, true)
        puts "  -> Membuat Scheme '#{name}'"
    end
    puts "Schemes berhasil dibuat."
end

def update_info_plist_instructions(info_plist_path)
  puts "\n--- TINDAKAN MANUAL DIPERLUKAN ---"
  puts "Skrip telah selesai. Satu langkah manual terakhir diperlukan:"
  puts "1. Buka file '#{info_plist_path}' di Xcode atau editor teks."
  puts "2. Temukan kunci 'CFBundleName' dan ganti nilainya dengan '$(APP_DISPLAY_NAME)'."
  puts "   <key>CFBundleName</key>"
  puts "   <string>$(APP_DISPLAY_NAME)</string>"
  puts "3. Temukan kunci 'CFBundleIdentifier' dan ganti nilainya dengan '$(PRODUCT_BUNDLE_IDENTIFIER)'."
  puts "   <key>CFBundleIdentifier</key>"
  puts "   <string>$(PRODUCT_BUNDLE_IDENTIFIER)</string>"
  puts "------------------------------------"
end


# --- Main Execution ---
puts "Memulai skrip konfigurasi flavor untuk iOS..."

flavors = parse_flavors(android_gradle_file)
if flavors.empty?
  puts "Tidak ada flavor yang ditemukan. Keluar."
  exit
end

create_xcconfig_files(flavors, configs_dir)
update_xcode_project(ios_project_path, flavors, configs_dir)
create_schemes(ios_project_path, flavors)
update_info_plist_instructions(ios_info_plist_path)

puts "\nKonfigurasi iOS untuk semua flavor telah selesai!"