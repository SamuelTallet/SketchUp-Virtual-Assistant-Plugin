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
    # @return [Boolean]
    def self.select_first_entity

      model = Sketchup.active_model

      entity = model.active_entities.first

      return false if entity.nil?

      model.selection.add(entity)

      true

    end

    # Selects first group.
    #
    # @return [Boolean]
    def self.select_first_group

      model = Sketchup.active_model

      group = model.active_entities.grep(Sketchup::Group).first

      return false if group.nil?

      model.selection.add(group)

      true

    end

    # Selects first component.
    #
    # @return [Boolean]
    def self.select_first_component

      model = Sketchup.active_model

      component = model.active_entities.grep(Sketchup::ComponentInstance).first

      return false if component.nil?

      model.selection.add(component)

      true

    end

    # Move selection along axes...
    #
    # @param [Length] x
    # @param [Length] y
    # @param [Length] z
    #
    # @return [Boolean]
    def self.move_selection(x, y, z)

      model = Sketchup.active_model

      selection = model.selection.first

      return false if selection.nil?

      transformation = Geom::Transformation.translation(
        Geom::Vector3d.new(x, y, z)
      )

      selection.transform!(transformation)

      true

    end

    # Rotates selection by n degrees.
    #
    # @param [Integer] angle
    #
    # @return [Boolean]
    def self.rotate_selection(angle)

      model = Sketchup.active_model

      selection = model.selection.first

      return false if selection.nil?

      transformation = Geom::Transformation.rotation(
        Geom::Point3d.new,
        Z_AXIS,
        angle.degrees
      )

      selection.transform!(transformation)

      true

    end

    # Increases selection size n times.
    #
    # @param [Float] scale
    #
    # @return [Boolean]
    def self.scale_selection(scale)

      model = Sketchup.active_model

      selection = model.selection.first

      return false if selection.nil?

      transformation = Geom::Transformation.scaling(
        selection.bounds.center,
        scale
      )

      selection.transform!(transformation)

      true

    end

  end

end
