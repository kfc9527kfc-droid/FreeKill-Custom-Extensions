local rule = fk.CreateSkill {
  name = "#loyal_traitor_rule&",
}

rule:addEffect("visibility", {
  role_visible = function(self, player, target)
    if player.role == "rebel" and target.role == "rebel" then
      return true
    end
  end,
})

return rule
