class_name UIStyle
extends RefCounted
const KIT = preload("res://game/scripts/ui/crystal_kit.gd")

const CREAM := Color("f4e8cb")
const MUTED := Color("c1bca9")
const GOLD := Color("f4c875")
const BLUE := Color("83d9e8")
const PANEL := Color("191727")


static func style_label(label: Label, font_size: int, color: Color) -> void:
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)


static func panel_style(background: Color, border: Color = Color("5f4d72")) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = background
	style.border_color = border
	style.set_border_width_all(2)
	style.set_corner_radius_all(2)
	style.content_margin_left = 12
	style.content_margin_top = 10
	style.content_margin_right = 12
	style.content_margin_bottom = 10
	return style


static func classic_style(kind := "panel") -> StyleBoxTexture:
	return KIT.style(kind, 6.0 if kind == "slot" else 14.0)

static func icon(id: String) -> Texture2D:
	return KIT.texture(id) if KIT.REGIONS.has(id) or id == "main_hand" else null

static func picture(texture: Texture2D, dimensions: Vector2) -> TextureRect:
	var rect := TextureRect.new()
	rect.texture = texture
	rect.custom_minimum_size = dimensions
	rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	rect.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return rect

static func style_button(button: Button, primary := false) -> void:
	button.add_theme_font_size_override("font_size", 18)
	button.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	button.add_theme_color_override("font_color", Color("281b16") if primary else CREAM)
	button.add_theme_color_override("font_focus_color", Color("281b16") if primary else CREAM)
	button.add_theme_color_override("font_disabled_color", Color("938e7e"))
	button.add_theme_color_override("font_hover_color", Color.WHITE)
	button.add_theme_color_override("font_pressed_color", Color("281b16"))
	for state in ["normal", "hover", "pressed", "disabled"]:
		var art: String = ("confirm" if primary else "button") if state == "normal" else str(state)
		var box := KIT.style(art)
		button.add_theme_stylebox_override(state, box)
	var focus := StyleBoxFlat.new()
	focus.bg_color = Color.TRANSPARENT
	focus.border_color = BLUE
	focus.set_border_width_all(2)
	button.add_theme_stylebox_override("focus", focus)


