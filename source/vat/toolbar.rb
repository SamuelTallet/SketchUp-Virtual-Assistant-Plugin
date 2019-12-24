# Virtual Assistant extension for SketchUp 2017 or newer.
# Copyright: © 2019 Samuel Tallet <samuel.tallet arobase gmail.com>
# 
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3.0 of the License, or
# (at your option) any later version.
# 
# If you release a modified version of this program TO THE PUBLIC,
# the GPL requires you to MAKE THE MODIFIED SOURCE CODE AVAILABLE
# to the program's users, UNDER THE GPL.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
# General Public License for more details.
# 
# Get a copy of the GPL here: https://www.gnu.org/licenses/gpl.html

raise 'The VAT plugin requires at least Ruby 2.2.0 or SketchUp 2017.'\
  unless RUBY_VERSION.to_f >= 2.2 # SketchUp 2017 includes Ruby 2.2.4.

require 'fileutils'
require 'sketchup'
require 'vat/chat_room'

# VAT plugin namespace.
module VAT

  # Toolbar of VAT plugin.
  class Toolbar

    # Absolute path to icons.
    ICONS_PATH = File.join(__dir__, 'Toolbar Icons').freeze

    private_constant :ICONS_PATH

    # Initializes instance.
    def initialize

      @toolbar = UI::Toolbar.new(TRANSLATE['Virtual Assistant'])

    end

    # Returns extension of icons depending on platform...
    #
    # @return [String] Extension. PDF (Mac) or SVG (Win).
    private def icon_extension

      if Sketchup.platform == :platform_osx
        '.pdf'
      else
        '.svg'
      end

    end

    # Adds "Chat with Virtual Assistant..." command.
    #
    # @return [nil]
    private def add_chat_with_virtual_assistant

      command = UI::Command.new('cva') do

        ChatRoom.new.html_dialog.show

      end

      command.small_icon = File.join(ICONS_PATH, 'cva'.concat(icon_extension))
      command.large_icon = File.join(ICONS_PATH, 'cva'.concat(icon_extension))

      command.tooltip = TRANSLATE['Chat with Virtual Assistant...']

      @toolbar.add_item(command)

      nil

    end

    # Prepares.
    #
    # @return [UI::Toolbar] Toolbar instance.
    def prepare

      add_chat_with_virtual_assistant

      @toolbar

    end

  end

end
