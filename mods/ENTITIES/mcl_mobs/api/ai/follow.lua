function mcl_mobs.mob:check_following()
    --ignore
    if not self.follow then
        self.following_person = nil
        return false
    end

    --hey look, this thing works for passive mobs too!
    local follower = mobs.detect_closest_player_within_radius(self,true,self.view_range,self.eye_height)

    --check if the follower is a player incase they log out
    if follower and follower:is_player() then
        local stack = follower:get_wielded_item()
        --safety check
        if not stack then
            self.following_person = nil
            return(false)
        end

        local item_name = stack:get_name()
        --all checks have passed, that guy has some good looking food
        if item_name == self.follow then
            self.following_person = follower
            return(true)
        end
    end

    --everything failed
    self.following_person = nil
    return(false)
end
