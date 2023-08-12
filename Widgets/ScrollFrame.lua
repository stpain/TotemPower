local name, addon = ...;

TotemPowerWrathEraScrollFrameMixin = {}
function TotemPowerWrathEraScrollFrameMixin:OnLoad()
    self.ScrollBar:ClearAllPoints()
    self.ScrollBar:SetPoint("TOPRIGHT", self, "TOPRIGHT", -2, -20)
    self.ScrollBar:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", -2, 20)
end