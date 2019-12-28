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

require 'sketchup'

# VAT plugin namespace.
module VAT

  # SketchUp entities.
  module Entities

    # Selects first entity.
    #
    # @return [nil, Boolean]
    def self.select_first_entity

      model = Sketchup.active_model

      entity = model.active_entities.first

      return nil if entity.nil?

      model.selection.add(entity)

      true

    end

    # Selects first group.
    #
    # @return [nil, Boolean]
    def self.select_first_group

      model = Sketchup.active_model

      group = model.active_entities.grep(Sketchup::Group).first

      return nil if group.nil?

      model.selection.add(group)

      true

    end

    # Selects groups named "x".
    #
    # @return [nil, Boolean]
    def self.select_groups_named(name)

      model = Sketchup.active_model

      groups = model.active_entities.grep(Sketchup::Group).find_all { |group|

        group.name.downcase == name.downcase

      }

      return nil if groups.empty?

      model.selection.add(groups)

      true

    end

    # Selects first component.
    #
    # @return [nil, Boolean]
    def self.select_first_component

      model = Sketchup.active_model

      component = model.active_entities.grep(Sketchup::ComponentInstance).first

      return nil if component.nil?

      model.selection.add(component)

      true

    end

    # Selects components named "x".
    #
    # @return [nil, Boolean]
    def self.select_components_named(name)

      model = Sketchup.active_model

      components = model.active_entities\
        .grep(Sketchup::ComponentInstance).find_all { |component|

        component.name.downcase == name.downcase

      }

      return nil if components.empty?

      model.selection.add(components)

      true

    end

    # Move selection along axes...
    #
    # @param [Length] x
    # @param [Length] y
    # @param [Length] z
    #
    # @return [nil, Boolean]
    def self.move_selection(x, y, z)

      model = Sketchup.active_model

      selection = model.selection.entries

      return nil if selection.empty?

      selected_grouponents = []

      selection.each { |entity|

        if entity.is_a?(Sketchup::Group)\
          || entity.is_a?(Sketchup::ComponentInstance)

          selected_grouponents.push(entity)

        end

      }

      return false if selected_grouponents.empty?

      selected_grouponents.each { |grouponent|

        transformation = Geom::Transformation.translation(
          Geom::Vector3d.new(x, y, z)
        )

        grouponent.transform!(transformation)

      }

      true

    end

    # Rotates selection by n degrees.
    #
    # @param [Integer] angle
    #
    # @return [nil, Boolean]
    def self.rotate_selection(angle)

      model = Sketchup.active_model

      selection = model.selection.entries

      return nil if selection.empty?

      selected_grouponents = []

      selection.each { |entity|

        if entity.is_a?(Sketchup::Group)\
          || entity.is_a?(Sketchup::ComponentInstance)

          selected_grouponents.push(entity)

        end

      }

      return false if selected_grouponents.empty?

      selected_grouponents.each { |grouponent|

        transformation = Geom::Transformation.rotation(
          Geom::Point3d.new,
          Z_AXIS,
          angle.degrees
        )

        grouponent.transform!(transformation)

      }

      true

    end

    # Increases selection size n times.
    #
    # @param [Float] scale
    #
    # @return [nil, Boolean]
    def self.scale_selection(scale)

      model = Sketchup.active_model

      selection = model.selection.entries

      return nil if selection.empty?

      selected_grouponents = []

      selection.each { |entity|

        if entity.is_a?(Sketchup::Group)\
          || entity.is_a?(Sketchup::ComponentInstance)

          selected_grouponents.push(entity)

        end

      }

      return false if selected_grouponents.empty?

      selected_grouponents.each { |grouponent|

        transformation = Geom::Transformation.scaling(
          grouponent.bounds.center,
          scale
        )

        grouponent.transform!(transformation)

      }

      true

    end

    # Rename selection.
    #
    # @param [String] name
    #
    # @return [nil, Boolean]
    def self.rename_selection(name)

      model = Sketchup.active_model

      selection = model.selection.entries

      return nil if selection.empty?

      selected_grouponents = []

      selection.each { |entity|

        if entity.is_a?(Sketchup::Group)\
          || entity.is_a?(Sketchup::ComponentInstance)

          selected_grouponents.push(entity)

        end

      }

      return false if selected_grouponents.empty?

      selected_grouponents.each { |grouponent|

        grouponent.name = name

      }

      true

    end

    # Copies selection and name copied entities "x".
    #
    # @return [nil, Boolean]
    def self.copy_selection(name)

      model = Sketchup.active_model

      selection = model.selection.entries

      return nil if selection.empty?

      selected_grouponents = []

      selection.each { |entity|

        if entity.is_a?(Sketchup::Group)\
          || entity.is_a?(Sketchup::ComponentInstance)

          selected_grouponents.push(entity)

        end

      }

      return false if selected_grouponents.empty?

      selected_grouponents.each { |original_grouponent|

        if original_grouponent.is_a?(Sketchup::Group)

          cloned_grouponent = original_grouponent.copy
          cloned_grouponent.material = original_grouponent.material

        else # if original_grouponent.is_a?(Sketchup::ComponentInstance)

          cloned_grouponent = model.entities.add_instance(
            original_grouponent.definition,
            Geom::Transformation.new
          )

        end

        cloned_grouponent.name = name

      }

      true

    end

    # Clears selection.
    #
    # @return [nil]
    def self.clear_selection

      Sketchup.active_model.selection.clear

    end

    # Erases selected entities.
    #
    # @return [nil, Boolean]
    def self.erase_selected_entities

      model = Sketchup.active_model

      selection = model.selection.entries

      return nil if selection.empty?

      model.active_entities.erase_entities(selection)

      true

    end

    # Writes text "x".
    #
    # @return [Boolean]
    def self.write_text(text)

      Sketchup.active_model.entities.add_3d_text(

        text, # string
        TextAlignLeft, # alignment
        'Arial', # font
        true, # is_bold
        false, # is_italic
        1.m, # letter_height
        0.0, # tolerance
        0.0, # z
        true, # is_filled
        10.cm # extrusion

      )

    end

  end

end
