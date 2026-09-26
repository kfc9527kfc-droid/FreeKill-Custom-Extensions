local rule = fk.CreateSkill {
  name = "#insanity_rule&",
}

rule:addEffect("visibility", {
  role_visible = function(self, player, target)
    if target:getMark("@!insane-noclear") ~= 0 then
      if player == target then
        return false
      elseif player.role == "lord" and not Fk:currentRoom():getSettings("lordIsInsane") then
        return true
      end
    end
  end,
})

return rule
