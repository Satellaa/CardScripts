--メルフィータイム
--Melffy Playhouse
--Scripted by Eerie Code
local s,id=GetID()
function s.initial_effect(c)
	--Return cards your opponent controls to the hand
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(100)
	return true
end
function s.filter(c)
	return c:IsFaceup() and c:IsRace(RACE_BEAST) and c:IsType(TYPE_XYZ)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(tp) and chkc:IsAbleToHand() end
	local dg=Duel.GetMatchingGroup(s.filter,tp,LOCATION_MZONE,0,nil)
	if chk==0 then
		if e:GetLabel()==100 then
			e:SetLabel(0)
			return Duel.CheckRemoveOverlayCard(tp,0,0,1,REASON_COST,dg)
				and Duel.IsExistingTarget(Card.IsAbleToHand,tp,0,LOCATION_ONFIELD,1,nil)
		else return false end
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVEXYZ)
	local ct=0
	for tc in dg:Iter() do
		ct=ct+tc:GetOverlayCount()
	end
	local count=Duel.RemoveOverlayCard(tp,0,0,1,ct,REASON_COST,dg)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
	local g=Duel.SelectTarget(tp,Card.IsAbleToHand,tp,0,LOCATION_ONFIELD,1,count,nil)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,#g,0,0)
	e:SetLabel(count)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetTargetCards(e)
	if #g>0 then Duel.SendtoHand(g,nil,REASON_EFFECT) end
	local ct=e:GetLabel()
	Duel.GetMatchingGroup(s.filter,tp,LOCATION_MZONE,0,nil):ForEach(s.op,e:GetHandler(),ct*500)
end
function s.op(tc,c,atk)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(atk)
	e1:SetReset(RESETS_STANDARD_PHASE_END)
	tc:RegisterEffect(e1)
end