local TextService = game:GetService("TextService")

local Rojo = script:FindFirstAncestor("Rojo")
local Plugin = Rojo.Plugin
local Packages = Rojo.Packages

local Roact = require(Packages.Roact)

local Settings = require(Plugin.Settings)
local Theme = require(Plugin.App.Theme)
local TextButton = require(Plugin.App.Components.TextButton)
local Header = require(Plugin.App.Components.Header)
local StudioPluginGui = require(Plugin.App.Components.Studio.StudioPluginGui)
local Tooltip = require(Plugin.App.Components.Tooltip)
local PatchVisualizer = require(script.PatchVisualizer)

local e = Roact.createElement

local ConfirmingPage = Roact.Component:extend("ConfirmingPage")

function ConfirmingPage:init()
	self.contentSize, self.setContentSize = Roact.createBinding(0)
	self.containerSize, self.setContainerSize = Roact.createBinding(Vector2.new(0, 0))
end

function ConfirmingPage:render()
	return Theme.with(function(theme)
		local pageContent = Roact.createFragment({
			Header = e(Header, {
				transparency = self.props.transparency,
				layoutOrder = 1,
			}),

			Title = e("TextLabel", {
				Text = string.format(
					"Sync changes for project '%s':",
					self.props.confirmData.serverInfo.projectName or "UNKNOWN"
				),
				LayoutOrder = 2,
				Font = Enum.Font.Gotham,
				LineHeight = 1.2,
				TextSize = 14,
				TextColor3 = theme.Settings.Setting.DescriptionColor,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextTransparency = self.props.transparency,
				Size = UDim2.new(1, 0, 0, 20),
				BackgroundTransparency = 1,
			}),

			PatchVisualizer = e(PatchVisualizer, {
				size = UDim2.new(1, 0, 1, -150),
				patch = self.props.confirmData.patch,
				instanceMap = self.props.confirmData.instanceMap,
				transparency = self.props.transparency,
				layoutOrder = 3,
			}),

			Buttons = e("Frame", {
				Size = UDim2.new(1, 0, 0, 34),
				LayoutOrder = 4,
				BackgroundTransparency = 1,
			}, {
				Abort = e(TextButton, {
					text = "Abort",
					style = "Bordered",
					transparency = self.props.transparency,
					layoutOrder = 1,
					onClick = self.props.onAbort,
				}, {
					Tip = e(Tooltip, {
						text = "Stop the connection process"
					}),
				}),

				Reject = if Settings:get("twoWaySync")
					then e(TextButton, {
						text = "Reject",
						style = "Bordered",
						transparency = self.props.transparency,
						layoutOrder = 2,
						onClick = self.props.onReject,
					}, {
						Tip = e(Tooltip, {
							text = "Push Studio changes to the Rojo server"
						}),
					})
					else nil,

				Accept = e(TextButton, {
					text = "Accept",
					style = "Solid",
					transparency = self.props.transparency,
					layoutOrder = 3,
					onClick = self.props.onAccept,
				}, {
					Tip = e(Tooltip, {
						text = "Pull Rojo server changes to Studio"
					}),
				}),

				Layout = e("UIListLayout", {
					HorizontalAlignment = Enum.HorizontalAlignment.Right,
					FillDirection = Enum.FillDirection.Horizontal,
					SortOrder = Enum.SortOrder.LayoutOrder,
					Padding = UDim.new(0, 10),
				}),
			}),

			Layout = e("UIListLayout", {
				HorizontalAlignment = Enum.HorizontalAlignment.Center,
				VerticalAlignment = Enum.VerticalAlignment.Center,
				FillDirection = Enum.FillDirection.Vertical,
				SortOrder = Enum.SortOrder.LayoutOrder,
				Padding = UDim.new(0, 10),
			}),

			Padding = e("UIPadding", {
				PaddingLeft = UDim.new(0, 20),
				PaddingRight = UDim.new(0, 20),
			}),
		})

		return if self.props.createPopup
			then e(StudioPluginGui, {
				id = "Rojo_DiffSync",
				title = string.format(
					"Confirm sync for project '%s':",
					self.props.confirmData.serverInfo.projectName or "UNKNOWN"
				),
				active = true,

				initDockState = Enum.InitialDockState.Float,
				initEnabled = true,
				overridePreviousState = true,
				floatingSize = Vector2.new(500, 350),
				minimumSize = Vector2.new(400, 250),

				zIndexBehavior = Enum.ZIndexBehavior.Sibling,

				onClose = self.props.onAbort,
			}, pageContent)
			else pageContent
	end)
end

return ConfirmingPage
