class_name UIStyle
extends RefCounted

const CREAM := Color("f4e8cb")
const MUTED := Color("bfb5c7")
const GOLD := Color("f4c875")
const BLUE := Color("83d9e8")
const PANEL := Color("241d31")


static func style_label(label: Label, font_size: int, color: Color) -> void:
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)


static func panel_style(background: Color, border: Color = Color("5f4d72")) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = background
	style.border_color = border
	style.set_border_width_all(2)
	style.set_corner_radius_all(10)
	style.content_margin_left = 12
	style.content_margin_top = 10
	style.content_margin_right = 12
	style.content_margin_bottom = 10
	return style


static func style_button(button: Button, primary := false) -> void:
	button.add_theme_font_size_override("font_size", 18)
	button.add_theme_color_override("font_color", CREAM)
	button.add_theme_color_override("font_hover_color", GOLD)
	button.add_theme_color_override("font_pressed_color", BLUE)
	var fill := Color("55406d") if primary else Color("32283f")
	button.add_theme_stylebox_override(
		"normal", panel_style(fill, Color("a77ce8") if primary else Color("77648b"))
	)
	button.add_theme_stylebox_override("hover", panel_style(Color("65517d"), GOLD))
	button.add_theme_stylebox_override("pressed", panel_style(Color("302744"), BLUE))
	button.add_theme_stylebox_override("focus", panel_style(fill, BLUE))
